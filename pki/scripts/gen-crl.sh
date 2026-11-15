#!/usr/bin/env bash
# Generates the intermediate CRL and publishes it with the public certificates.
set -euo pipefail
# shellcheck source=pki/scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  echo "Usage: gen-crl.sh" >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

openssl ca -batch -config "$INT_CNF" -gencrl -out "$PKI_INT_DIR/intermediate.crl" 2>/dev/null
cp "$PKI_INT_DIR/intermediate.crl" "$PKI_PUBLIC_DIR/"
cat "$PKI_PUBLIC_DIR/intermediate.crl" "$PKI_PUBLIC_DIR/root.crl" >"$PKI_PUBLIC_DIR/crls.pem"
revoked="$(grep -c '^R' "$PKI_INT_DIR/index.txt" || true)"
echo "CRL $(openssl crl -in "$PKI_PUBLIC_DIR/intermediate.crl" -noout -crlnumber) revoked=$revoked"
