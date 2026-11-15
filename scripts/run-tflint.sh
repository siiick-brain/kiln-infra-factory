#!/usr/bin/env bash
# Runs TFLint on every module and example directory. Policy fixtures are skipped because they are
# deliberately incomplete inputs for Conftest. Prints one line per directory.
set -euo pipefail

usage() {
  echo "Usage: scripts/run-tflint.sh" >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export TFLINT_DISABLE_VERSION_CHECK=1
findings=0
dirs=0
while IFS= read -r dir; do
  dirs=$((dirs + 1))
  rc=0
  out="$(tflint --chdir "$dir" --config "$repo/.tflint.hcl" --format compact 2>&1)" || rc=$?
  count="$(printf '%s\n' "$out" | grep -cE ': (Warning|Error|Notice) ' || true)"
  # TFLint exits 2 when it reports findings. Any other non-zero exit is a tool failure, not a clean result.
  if ((rc != 0 && rc != 2)) || ((rc == 2 && count == 0)); then
    count=$((count + 1))
    out="$out"$'\n'"$dir: Error - tflint exited $rc"
  fi
  findings=$((findings + count))
  if ((count == 0)); then echo "PASS ${dir#"$repo"/}"; else
    echo "FAIL ${dir#"$repo"/} findings=$count"
    printf '%s\n' "$out" | grep -E ': (Warning|Error|Notice) ' | head -5
  fi
done < <(find "$repo/modules" -name '*.tf' -not -path '*/.terraform/*' -printf '%h\n' | sort -u)
echo "TFLint: $dirs directories, $findings findings"
((findings == 0))
