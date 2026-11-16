#!/usr/bin/env bash
# Extends a PCR with the SHA-256 digest of an event string and prints the new PCR value.
set -euo pipefail
# shellcheck source=tpm/scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  echo "Usage: extend-pcr.sh <pcr-index> <event-text>" >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi
if (($# != 2)); then
  usage
  exit 2
fi

digest="$(printf '%s' "$2" | sha256sum | cut -d' ' -f1)"
tpm2_pcrextend "$1:sha256=$digest"
tpm2_pcrread "sha256:$1"
