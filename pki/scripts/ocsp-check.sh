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
out="$(openssl ocsp -issuer "$PKI_PUBLIC_DIR/intermediate.crt" -cert "$1" -url "$url" \
  -CAfile "$PKI_PUBLIC_DIR/chain.pem" -timeout 10 -resp_text 2>&1 || true)"
grep -E "^$1: |Response verify|Revocation Reason" <<<"$out" || true
# Exit 0 for good, 1 for revoked or unknown, 3 when no status came back.
if grep -q "^$1: good" <<<"$out"; then exit 0; fi
if grep -qE "^$1: (revoked|unknown)" <<<"$out"; then exit 1; fi
echo "ERROR: no OCSP status for $1" >&2
exit 3
