#!/usr/bin/env bash
# Unseals the secret. Succeeds only while PCR 16 still matches the value recorded at seal time.
set -euo pipefail
# shellcheck source=tpm/scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  echo "Usage: unseal.sh" >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi
load_primary
[[ -f "$TPM_WORK/seal.pub" ]] || die "run seal.sh first"

tpm2_load -C "$TPM_WORK/primary.ctx" -u "$TPM_WORK/seal.pub" -r "$TPM_WORK/seal.priv" -c "$TPM_WORK/seal.ctx" >/dev/null
tpm2_unseal -c "$TPM_WORK/seal.ctx" -p "pcr:sha256:$SEAL_PCR"
