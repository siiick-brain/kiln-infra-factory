#!/usr/bin/env bash
# Root key ceremony: creates the ECDSA P-384 root CA and signs the intermediate CA with pathlen 0.
# Run only while the root volume is mounted. Afterwards unmount it and keep it offline.
set -euo pipefail
# shellcheck source=pki/scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  echo "Usage: ceremony.sh" >&2
  echo "Creates the root and intermediate CAs under PKI_HOME (default /pki)." >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

refuse_repo_path "$PKI_HOME"
[[ ! -f "$PKI_ROOT_DIR/root.crt" ]] || die "root CA already exists in $PKI_ROOT_DIR"

umask 077
init_ca_dir "$PKI_ROOT_DIR"
init_ca_dir "$PKI_INT_DIR"
mkdir -p "$PKI_PUBLIC_DIR" "$PKI_ISSUED_DIR"

echo "step 1: root key (ECDSA P-384)"
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-384 -out "$PKI_ROOT_DIR/private/root.key"
echo "step 2: self-signed root certificate (10 years)"
openssl req -config "$ROOT_CNF" -new -x509 -key "$PKI_ROOT_DIR/private/root.key" \
  -days 3650 -extensions v3_root -out "$PKI_ROOT_DIR/root.crt"

echo "step 3: intermediate key and CSR"
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-384 -out "$PKI_INT_DIR/private/intermediate.key"
openssl req -config "$INT_CNF" -new -key "$PKI_INT_DIR/private/intermediate.key" -out "$PKI_INT_DIR/intermediate.csr"

echo "step 4: root signs the intermediate (5 years, pathlen 0)"
openssl ca -batch -config "$ROOT_CNF" -extensions v3_intermediate -days 1825 -notext \
  -in "$PKI_INT_DIR/intermediate.csr" -out "$PKI_INT_DIR/intermediate.crt" 2>/dev/null

echo "step 5: root CRL"
openssl ca -batch -config "$ROOT_CNF" -gencrl -out "$PKI_ROOT_DIR/root.crl" 2>/dev/null

umask 022
cp "$PKI_ROOT_DIR/root.crt" "$PKI_ROOT_DIR/root.crl" "$PKI_INT_DIR/intermediate.crt" "$PKI_PUBLIC_DIR/"
cat "$PKI_INT_DIR/intermediate.crt" "$PKI_ROOT_DIR/root.crt" >"$PKI_PUBLIC_DIR/chain.pem"

echo "step 6: OCSP responder certificate"
"$SCRIPT_DIR/csr.sh" ocsp ocsp.kiln.test "DNS:ocsp.kiln.test" >/dev/null
"$SCRIPT_DIR/issue.sh" ocsp ocsp_cert >/dev/null
"$SCRIPT_DIR/gen-crl.sh" >/dev/null

echo "Root fingerprint (record in the ceremony log):"
openssl x509 -in "$PKI_ROOT_DIR/root.crt" -noout -fingerprint -sha256
echo "Ceremony complete. Unmount the root volume now."
