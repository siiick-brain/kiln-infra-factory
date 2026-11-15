#!/usr/bin/env bash
# Rotates a leaf certificate with overlap. A new key and certificate replace the current pair.
# The previous pair stays valid in previous/ until it expires or is revoked.
# --deploy pushes the new pair to the nginx target through Ansible with a graceful reload.
set -euo pipefail
# shellcheck source=pki/scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  echo "Usage: rotate.sh <name> [--deploy]" >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi
if (($# < 1)); then
  usage
  exit 2
fi

name="$1"
dir="$PKI_ISSUED_DIR/$name"
[[ -f "$dir/cert.pem" ]] || die "nothing to rotate at $dir"
cn="$(openssl x509 -in "$dir/cert.pem" -noout -subject -nameopt multiline | awk -F' = ' '/commonName/ {print $2}')"
profile="$(cat "$dir/profile.txt" 2>/dev/null || echo server_cert)"
old_serial="$(openssl x509 -in "$dir/cert.pem" -noout -serial)"

rm -rf "$dir/previous"
mkdir -p "$dir/previous"
cp -p "$dir/key.pem" "$dir/cert.pem" "$dir/previous/"
"$SCRIPT_DIR/csr.sh" "$name" "$cn" "$(cat "$dir/san.txt")" >/dev/null
"$SCRIPT_DIR/issue.sh" "$name" "$profile" >/dev/null
new_serial="$(openssl x509 -in "$dir/cert.pem" -noout -serial)"
echo "ROTATED $name old=${old_serial#serial=} new=${new_serial#serial=}"

if [[ "${2:-}" == "--deploy" ]]; then
  repo="$(cd "$PKI_CONF_DIR/../.." && pwd)"
  ansible-playbook -i "$repo/ansible/inventory.yml" "$repo/ansible/pki-deploy.yml" \
    -e "cert_deploy_certificate_source=$dir/fullchain.pem" \
    -e "cert_deploy_private_key_source=$dir/key.pem"
fi
