#!/usr/bin/env bash
# Creates an ECC P-256 primary storage key under the owner hierarchy and saves its context.
set -euo pipefail
# shellcheck source=tpm/scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  echo "Usage: create-primary.sh" >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

tpm2_createprimary -C o -g sha256 -G ecc256 -c "$TPM_WORK/primary.ctx" >/dev/null
echo "PRIMARY $TPM_WORK/primary.ctx"
