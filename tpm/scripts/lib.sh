#!/usr/bin/env bash
# Shared settings for the TPM scripts. Sourced, not executed.
# The target is swtpm, a software TPM. It is not a hardware root of trust.
set -euo pipefail

export TPM2TOOLS_TCTI="${TPM2TOOLS_TCTI:-swtpm:host=swtpm,port=2321}"
TPM_WORK="${TPM_WORK:-/tmp/kiln-tpm}"
SEAL_PCR="${SEAL_PCR:-16}"
NV_INDEX="${NV_INDEX:-0x1500016}"
export TPM_WORK SEAL_PCR NV_INDEX
mkdir -p "$TPM_WORK"
chmod 700 "$TPM_WORK"

die() {
  echo "ERROR: $*" >&2
  exit 1
}

# swtpm runs without a resource manager, so transient objects and sessions are flushed after each step.
flush() {
  tpm2_flushcontext -t >/dev/null 2>&1 || true
  tpm2_flushcontext -s >/dev/null 2>&1 || true
}
trap flush EXIT

load_primary() {
  [[ -f "$TPM_WORK/primary.ctx" ]] || die "run provision.sh first"
}
