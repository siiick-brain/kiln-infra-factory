#!/usr/bin/env bash
# Runs terragrunt run --all validate for every unit in every environment, then plan, apply and
# destroy for the AWS units of each environment against the Moto emulator. Azure and GCP units
# validate only. Prints one line per step. Full output goes to artifacts/logs/terragrunt/.
set -euo pipefail

usage() {
  echo "Usage: scripts/terragrunt-run-all.sh [env ...]" >&2
  echo "Default environments: dev stage prod. Runs inside the toolbox with the emulator up." >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
logs="$repo/artifacts/logs/terragrunt"
mkdir -p "$logs"
envs=("$@")
((${#envs[@]} > 0)) || envs=(dev stage prod)

declare -A result=([validate]=0 [plan]=0 [apply]=0 [destroy]=0)
step() {
  local name="$1" dir="$2" log="$3"
  shift 3
  if terragrunt run --all --parallelism 1 --non-interactive --working-dir "$dir" -- "$@" >"$log" 2>&1; then
    echo "PASS $name ${dir#"$repo"/}"
  else
    echo "FAIL $name ${dir#"$repo"/} (see ${log#"$repo"/})"
    result[$name]=1
  fi
}

bash "$repo/scripts/bootstrap-state-bucket.sh" >/dev/null
for env in "${envs[@]}"; do
  step validate "$repo/live/$env" "$logs/$env-validate.log" validate -no-color
done
for env in "${envs[@]}"; do
  step plan "$repo/live/$env/aws" "$logs/$env-aws-plan.log" plan -no-color
  step apply "$repo/live/$env/aws" "$logs/$env-aws-apply.log" apply -auto-approve -no-color
  step destroy "$repo/live/$env/aws" "$logs/$env-aws-destroy.log" destroy -auto-approve -no-color
done

echo "Terragrunt run-all: validate=${result[validate]} plan=${result[plan]} apply=${result[apply]} destroy=${result[destroy]} (0 means every environment passed)"
((result[validate] + result[plan] + result[apply] + result[destroy] == 0))
