#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s [--help]\n' "${0##*/}"
  printf 'Create local demo state, migrate it to the Moto S3 backend and verify locking.\n'
}

if [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "$#" -ne 0 ]]; then
  usage >&2
  exit 2
fi

if ! command -v terraform >/dev/null 2>&1; then
  printf 'terraform is required. Run this script in the toolbox container.\n' >&2
  exit 127
fi

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
backend_config="$repo_root/backend/emulator.hcl"
if [[ ! -f "$backend_config" ]]; then
  printf 'Backend configuration is missing: %s\n' "$backend_config" >&2
  exit 1
fi

work_dir="$(mktemp -d)"
apply_pid=""
cleanup() {
  if [[ -n "$apply_pid" ]]; then
    wait "$apply_pid" 2>/dev/null || true
  fi
  rm -rf -- "$work_dir"
}
trap cleanup EXIT

bucket_name="kiln-state-migration-$(date +%s%N)"
cat > "$work_dir/main.tf" <<EOF
terraform {
  required_version = ">= 1.11.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.71.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  s3_use_path_style           = true
  access_key                  = "testing"
  secret_key                  = "testing"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  endpoints {
    s3 = "http://emulator:5000"
  }
}

module "state_bucket" {
  source = "$repo_root/modules/aws/state-bootstrap"

  bucket_name              = "$bucket_name"
  enforce_secure_transport = false
  tags = {
    Environment = "test"
    Owner       = "siiick-brain"
    Project     = "kiln-infra-factory"
  }
}

resource "terraform_data" "migration_probe" {
  input = "local state migrated to Moto"
}
EOF

printf 'Initializing local state fixture.\n'
terraform -chdir="$work_dir" init -backend=false -input=false -no-color
terraform -chdir="$work_dir" apply -auto-approve -input=false -no-color

printf 'Migrating local state to the Moto S3 backend.\n'
cat > "$work_dir/backend.tf" <<'EOF'
terraform {
  backend "s3" {}
}
EOF
terraform -chdir="$work_dir" init -migrate-state -force-copy -input=false -no-color \
  -backend-config="$backend_config" \
  -backend-config="bucket=$bucket_name" \
  -backend-config="key=state-migration/terraform.tfstate"

terraform -chdir="$work_dir" state list
terraform -chdir="$work_dir" state pull > "$work_dir/remote-state.json"
python - "$work_dir/remote-state.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as state_file:
    state = json.load(state_file)

addresses = {
    f"{resource.get('module', '')}.{resource['type']}.{resource['name']}".lstrip(".")
    for resource in state.get("resources", [])
}
if not any(a == "terraform_data.migration_probe" or a.endswith(".terraform_data.migration_probe") for a in addresses):
    raise SystemExit("Remote state does not contain the migration probe.")
print("Remote state object verified through the configured S3 backend.")
PY

cat > "$work_dir/lock.tf" <<EOF
resource "terraform_data" "lock_probe" {
  input = "concurrent apply lock test"
  provisioner "local-exec" {
    command = "touch $work_dir/lock-held && sleep 20"
  }
}
EOF

printf 'Starting the first apply and waiting for its lock-holder provisioner.\n'
terraform -chdir="$work_dir" apply -auto-approve -input=false -no-color \
  > "$work_dir/first-apply.log" 2>&1 &
apply_pid=$!
waited=0
while [[ ! -f "$work_dir/lock-held" ]]; do
  if ! kill -0 "$apply_pid" 2>/dev/null; then
    wait "$apply_pid" || true
    cat "$work_dir/first-apply.log" >&2
    printf 'The first apply exited before acquiring its test lock.\n' >&2
    exit 1
  fi
  if [[ "$waited" -ge 60 ]]; then
    cat "$work_dir/first-apply.log" >&2
    printf 'Timed out waiting for the first apply to acquire its lock.\n' >&2
    exit 1
  fi
  sleep 1
  waited=$((waited + 1))
done

set +e
second_output="$(terraform -chdir="$work_dir" apply -auto-approve -input=false -no-color 2>&1)"
second_status=$?
set -e
if [[ "$second_status" -eq 0 ]] || ! grep -qi 'state lock' <<< "$second_output"; then
  printf '%s\n' "$second_output" >&2
  printf 'The concurrent apply was not refused by the backend state lock.\n' >&2
  exit 1
fi
printf 'Concurrent apply refused by the S3 backend state lock.\n'

if ! wait "$apply_pid"; then
  cat "$work_dir/first-apply.log" >&2
  printf 'The first apply failed after the lock test.\n' >&2
  exit 1
fi
apply_pid=""
