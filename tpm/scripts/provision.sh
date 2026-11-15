#!/usr/bin/env bash
# Provisions the software TPM: startup, clear the owner hierarchy, reset PCR 16 and create the primary key.
set -euo pipefail
# shellcheck source=tpm/scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  echo "Usage: provision.sh" >&2
  echo "Clears the swtpm owner hierarchy and writes TPM_WORK/primary.ctx. Demonstration TPM only." >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

tpm2_startup -c 2>/dev/null || true
tpm2_clear -c p
tpm2_pcrreset "$SEAL_PCR"
"$(dirname "${BASH_SOURCE[0]}")/create-primary.sh"
echo "PROVISIONED software TPM (swtpm). Not a hardware root of trust."
