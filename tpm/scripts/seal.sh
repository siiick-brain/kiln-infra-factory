#!/usr/bin/env bash
# Seals a small secret to the current value of PCR 16 with a PCR policy.
set -euo pipefail
# shellcheck source=tpm/scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  echo "Usage: seal.sh <secret-file>" >&2
  echo "The secret must be 128 bytes or less. Use fake values for demonstrations." >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi
if (($# != 1)); then
  usage
  exit 2
fi
[[ -f "$1" ]] || die "secret file not found"
load_primary

tpm2_pcrread "sha256:$SEAL_PCR" -o "$TPM_WORK/pcr.bin" >/dev/null
tpm2_startauthsession -S "$TPM_WORK/session.ctx"
tpm2_policypcr -S "$TPM_WORK/session.ctx" -l "sha256:$SEAL_PCR" -f "$TPM_WORK/pcr.bin" -L "$TPM_WORK/pcr.policy" >/dev/null
tpm2_flushcontext "$TPM_WORK/session.ctx"
tpm2_create -C "$TPM_WORK/primary.ctx" -L "$TPM_WORK/pcr.policy" -a "fixedtpm|fixedparent" \
  -i "$1" -u "$TPM_WORK/seal.pub" -r "$TPM_WORK/seal.priv" >/dev/null
echo "SEALED to sha256:$SEAL_PCR"
