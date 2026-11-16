#!/usr/bin/env bash
# Signs a CSR with the intermediate CA using an extension profile from intermediate.cnf.
set -euo pipefail
# shellcheck source=pki/scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  echo "Usage: issue.sh <name> <profile> [days|--expired]" >&2
  echo "Profiles: server_cert client_cert ocsp_cert kube_apiserver kube_client kubelet_serving etcd_peer etcd_client" >&2
  echo "--expired issues a certificate whose validity ended in 2020, for negative tests only." >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi
if (($# < 2)); then
  usage
  exit 2
fi

name="$1"
profile="$2"
validity="${3:-90}"
dir="$PKI_ISSUED_DIR/$name"
[[ -f "$dir/csr.pem" ]] || die "no CSR at $dir/csr.pem"
grep -q "^\[ $profile \]" "$INT_CNF" || die "unknown profile $profile"
if [[ -f "$dir/san.txt" ]]; then
  SAN="$(cat "$dir/san.txt")"
  export SAN
fi

dates=(-days "$validity")
if [[ "$validity" == "--expired" ]]; then
  dates=(-startdate 20200101000000Z -enddate 20200102000000Z)
fi
if ! openssl ca -batch -config "$INT_CNF" -extensions "$profile" "${dates[@]}" -notext \
  -in "$dir/csr.pem" -out "$dir/cert.pem" 2>"$dir/issue.err"; then
  cat "$dir/issue.err" >&2
  exit 1
fi
printf '%s\n' "$profile" >"$dir/profile.txt"
cat "$dir/cert.pem" "$PKI_PUBLIC_DIR/intermediate.crt" >"$dir/fullchain.pem"
# The OCSP responder reads this published copy, so it never needs the CA private key volume.
cp "$PKI_INT_DIR/index.txt" "$PKI_PUBLIC_DIR/index.txt"
echo "ISSUED $name $(openssl x509 -in "$dir/cert.pem" -noout -serial) profile=$profile"
