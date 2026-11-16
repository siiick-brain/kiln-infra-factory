#!/usr/bin/env bash
# Creates a P-256 key and CSR for a leaf certificate under PKI_HOME/issued/<name>.
set -euo pipefail
# shellcheck source=pki/scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  echo "Usage: csr.sh <name> <common-name> <san-list> [organization]" >&2
  echo "Example: csr.sh web web.kiln.test DNS:web.kiln.test,IP:10.0.0.5" >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi
if (($# < 3)); then
  usage
  exit 2
fi

name="$1"
cn="$2"
san="$3"
org="${4:-Kiln Demo}"
[[ "$name" =~ ^[a-z0-9-]+$ ]] || die "name must use lowercase letters, digits or hyphens"
dir="$PKI_ISSUED_DIR/$name"
mkdir -p "$dir"
umask 077
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out "$dir/key.pem"
umask 022
openssl req -new -key "$dir/key.pem" -subj "/O=$org/CN=$cn" -out "$dir/csr.pem"
printf '%s\n' "$san" >"$dir/san.txt"
echo "CSR $dir/csr.pem"
