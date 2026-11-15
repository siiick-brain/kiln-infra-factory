#!/usr/bin/env bats

setup() {
  root="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  script="$root/scripts/migrate-state.sh"
  backend="$root/backend/emulator.hcl"
}

@test "migration script documents its invocation" {
  run bash "$script" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "migration script rejects unexpected arguments" {
  run bash "$script" unexpected
  [ "$status" -eq 2 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "migration script uses LF line endings" {
  ! LC_ALL=C grep -q $'\r' "$script"
}

@test "remote backend is configured after local state is applied" {
  local_apply_line="$(grep -n 'terraform -chdir="\$work_dir" apply -auto-approve' "$script" | head -n 1 | cut -d: -f1)"
  backend_line="$(grep -n 'backend "s3" {}' "$script" | head -n 1 | cut -d: -f1)"
  [ "$local_apply_line" -lt "$backend_line" ]
}

@test "AWS provider uses path style for Moto S3" {
  run grep -E 's3_use_path_style[[:space:]]*=[[:space:]]*true' "$script"
  [ "$status" -eq 0 ]
}

@test "backend uses the local emulator and native state locking" {
  run grep -F 'http://emulator:5000' "$backend"
  [ "$status" -eq 0 ]
  run grep -E 'use_lockfile[[:space:]]*=[[:space:]]*true' "$backend"
  [ "$status" -eq 0 ]
  run grep -E 'access_key[[:space:]]*=[[:space:]]*"testing"' "$backend"
  [ "$status" -eq 0 ]
}

@test "state verification accepts a root-module migration probe" {
  check="$BATS_TEST_TMPDIR/check.py"
  sed -n "/<<'PY'$/,/^PY$/p" "$BATS_TEST_DIRNAME/../scripts/migrate-state.sh" | sed '1d;$d' > "$check"
  printf '%s' '{"resources":[{"mode":"managed","type":"terraform_data","name":"migration_probe"}]}' > "$BATS_TEST_TMPDIR/state.json"
  run python3 "$check" "$BATS_TEST_TMPDIR/state.json"
  [ "$status" -eq 0 ]
}

@test "state verification rejects state without the probe" {
  check="$BATS_TEST_TMPDIR/check.py"
  sed -n "/<<'PY'$/,/^PY$/p" "$BATS_TEST_DIRNAME/../scripts/migrate-state.sh" | sed '1d;$d' > "$check"
  printf '%s' '{"resources":[{"mode":"managed","type":"terraform_data","name":"other"}]}' > "$BATS_TEST_TMPDIR/state.json"
  run python3 "$check" "$BATS_TEST_TMPDIR/state.json"
  [ "$status" -ne 0 ]
}
