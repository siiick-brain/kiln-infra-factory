#!/usr/bin/env bash
# Creates an endorsement key and an attestation key, quotes PCR 0 and 16 with a fresh nonce
# and verifies the quote with tpm2_checkquote. --wrong-nonce verifies against a different nonce.
set -euo pipefail
# shellcheck source=tpm/scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  echo "Usage: quote.sh [--wrong-nonce]" >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

w="$TPM_WORK"
flush
tpm2_createek -c "$w/ek.ctx" -G ecc -u "$w/ek.pub" >/dev/null
tpm2_createak -C "$w/ek.ctx" -c "$w/ak.ctx" -G ecc -g sha256 -s ecdsa -u "$w/ak.pub" -f pem -n "$w/ak.name" >/dev/null
# Free object and session slots before quoting. swtpm has no resource manager.
flush
nonce="$(openssl rand -hex 16)"
tpm2_quote -c "$w/ak.ctx" -l sha256:0,16 -q "$nonce" -m "$w/quote.msg" -s "$w/quote.sig" -o "$w/quote.pcrs" -g sha256 >/dev/null

check_nonce="$nonce"
if [[ "${1:-}" == "--wrong-nonce" ]]; then
  check_nonce="$(openssl rand -hex 16)"
fi
if tpm2_checkquote -u "$w/ak.pub" -m "$w/quote.msg" -s "$w/quote.sig" -f "$w/quote.pcrs" -g sha256 -q "$check_nonce" >/dev/null; then
  echo "QUOTE VERIFIED pcrs=sha256:0,16"
else
  echo "QUOTE FAILED"
  exit 1
fi
