#!/usr/bin/env bash
# Runs fmt, init, validate and terraform test for every module and its examples.
# Prints one line per module. Full output goes to artifacts/logs/modules/.
set -euo pipefail

usage() {
  echo "Usage: scripts/test-modules.sh [module-dir ...]" >&2
  echo "Without arguments every directory under modules/ that has a versions.tf is tested." >&2
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
logdir="$root/artifacts/logs/modules"
mkdir -p "$logdir"
export TF_PLUGIN_CACHE_DIR="${TF_PLUGIN_CACHE_DIR:-$root/.terraform-plugin-cache}"
export TF_IN_AUTOMATION=1
mkdir -p "$TF_PLUGIN_CACHE_DIR"

if (( $# > 0 )); then
  modules=("$@")
else
  mapfile -t modules < <(find "$root/modules" -name versions.tf -not -path '*/.terraform/*' -not -path '*/examples/*' -printf '%h\n' | sort)
fi

failed=0
total_tests=0
for dir in "${modules[@]}"; do
  rel="${dir#"$root"/}"
  log="$logdir/$(echo "$rel" | tr '/' '_').log"
  : > "$log"
  status="PASS"
  step="ok"
  for cmd in "fmt -check -recursive" "init -backend=false -input=false" "validate" "test"; do
    # shellcheck disable=SC2086
    if ! terraform -chdir="$dir" $cmd >> "$log" 2>&1; then
      status="FAIL"
      step="${cmd%% *}"
      break
    fi
  done
  tests="$(grep -Eo '[0-9]+ passed' "$log" | tail -1 | grep -Eo '[0-9]+' || echo 0)"
  if [[ "$status" == "PASS" ]]; then
    for ex in "$dir"/examples/*/; do
      [[ -d "$ex" ]] || continue
      if ! { terraform -chdir="$ex" init -backend=false -input=false && terraform -chdir="$ex" validate; } >> "$log" 2>&1; then
        status="FAIL"
        step="example $(basename "$ex")"
      fi
    done
  fi
  total_tests=$((total_tests + tests))
  [[ "$status" == "PASS" ]] || failed=$((failed + 1))
  printf '%s %-45s tests=%s step=%s\n' "$status" "$rel" "$tests" "$step"
done

echo "Modules: ${#modules[@]} checked, $failed failed, $total_tests terraform tests passed"
(( failed == 0 ))
