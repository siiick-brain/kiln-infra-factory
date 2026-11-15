#!/usr/bin/env bash
# Queries the OCSP responder for one certificate and prints good, revoked or unknown.
set -euo pipefail
# shellcheck source=pki/scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  echo "Usage: ocsp-check.sh <cert.pem> [url]" >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi
if (($# < 1)); then
  usage
  exit 2
fi

url="${2:-${OCSP_URL:-http://127.0.0.1:2560}}"
openssl ocsp -issuer "$PKI_PUBLIC_DIR/intermediate.crt" -cert "$1" -url "$url" \
  -CAfile "$PKI_PUBLIC_DIR/chain.pem" -timeout 10 -resp_text 2>&1 |
  grep -E "^$1: |Response verify|Revocation Reason" || true
