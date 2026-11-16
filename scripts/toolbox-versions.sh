#!/usr/bin/env bash
# Prints one line per toolbox tool with its version. Exits 1 if any tool is missing.
set -euo pipefail

usage() {
  echo "Usage: scripts/toolbox-versions.sh" >&2
  echo "Prints the version of every pinned toolbox tool, one per line." >&2
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

missing=0
check() {
  local name="$1"
  shift
  local out ver
  # Capture all output first so an early-closing pipe cannot fail the check.
  out="$("$@" 2>&1 || true)"
  ver="$(printf '%s\n' "$out" | grep -Eo '[0-9]+\.[0-9]+(\.[0-9]+)?' | awk 'NR==1' || true)"
  if [[ -n "$ver" ]]; then
    printf 'PASS %-16s %s\n' "$name" "$ver"
  else
    printf 'FAIL %-16s missing\n' "$name"
    missing=$((missing + 1))
  fi
}

check terraform terraform version
check terragrunt terragrunt --version
check tflint tflint --version
check checkov checkov --version
check opa opa version
check conftest conftest --version
check ansible ansible --version
check ansible-lint ansible-lint --version
check sops sops --version
check age age --version
check shellcheck shellcheck --version
check bats bats --version
check terraform-docs terraform-docs --version
check kubeconform kubeconform -v
check tpm2-tools tpm2_startup --version
check pytest-testinfra python -c "import importlib.metadata as m; print(m.version('pytest-testinfra'))"

if (( missing > 0 )); then
  echo "Toolbox versions: ${missing} missing"
  exit 1
fi
echo "Toolbox versions: all present"
