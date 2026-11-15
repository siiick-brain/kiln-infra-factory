#!/usr/bin/env bash
# Revokes an issued certificate with a CRL reason code. Run gen-crl.sh afterwards.
set -euo pipefail
# shellcheck source=pki/scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  echo "Usage: revoke.sh <name|cert-path> [reason]" >&2
  echo "Reasons: unspecified keyCompromise CACompromise affiliationChanged superseded cessationOfOperation" >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi
if (($# < 1)); then
  usage
  exit 2
fi

cert="$1"
[[ -f "$cert" ]] || cert="$PKI_ISSUED_DIR/$1/cert.pem"
[[ -f "$cert" ]] || die "certificate not found: $1"
reason="${2:-unspecified}"
openssl ca -batch -config "$INT_CNF" -revoke "$cert" -crl_reason "$reason" 2>/dev/null
echo "REVOKED $(openssl x509 -in "$cert" -noout -serial) reason=$reason"
