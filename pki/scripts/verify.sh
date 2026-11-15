#!/usr/bin/env bash
# Verifies a certificate against the Kiln root and intermediate. --crl adds a full-chain CRL check.
set -euo pipefail
# shellcheck source=pki/scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  echo "Usage: verify.sh <cert.pem> [--crl]" >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi
if (($# < 1)); then
  usage
  exit 2
fi

args=(-CAfile "$PKI_PUBLIC_DIR/root.crt" -untrusted "$PKI_PUBLIC_DIR/intermediate.crt")
if [[ "${2:-}" == "--crl" ]]; then
  args+=(-crl_check_all -CRLfile "$PKI_PUBLIC_DIR/crls.pem")
fi
openssl verify "${args[@]}" "$1"
