#!/usr/bin/env bats
# PKI behaviour: chain, wrong CA, expiry, CRL revocation, OCSP revocation and rotation.
# Keys live in a temporary directory inside the container and are removed afterwards.

setup_file() {
  export REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  export PKI_HOME="$(mktemp -d)"
  export PATH="$REPO/pki/scripts:$PATH"
  ceremony.sh > "$PKI_HOME/ceremony.log" 2>&1
  csr.sh web web.kiln.test "DNS:web.kiln.test,DNS:localhost"
  issue.sh web server_cert
  csr.sh old old.kiln.test "DNS:old.kiln.test"
  issue.sh old server_cert --expired
  csr.sh bad bad.kiln.test "DNS:bad.kiln.test"
  issue.sh bad server_cert
  revoke.sh bad keyCompromise
  gen-crl.sh
  ocsp-responder.sh start
}

teardown_file() {
  ocsp-responder.sh stop || true
  rm -rf "$PKI_HOME"
}

@test "root is ECDSA P-384 and intermediate has pathlen 0" {
  run openssl x509 -in "$PKI_HOME/public/root.crt" -noout -text
  [[ "$output" == *"NIST CURVE: P-384"* ]]
  run openssl x509 -in "$PKI_HOME/public/intermediate.crt" -noout -ext basicConstraints
  [[ "$output" == *"pathlen:0"* ]]
}

@test "leaf carries SAN, EKU, AKI, SKI, CRL distribution point and AIA OCSP" {
  run openssl x509 -in "$PKI_HOME/issued/web/cert.pem" -noout -text
  [[ "$output" == *"DNS:web.kiln.test"* ]]
  [[ "$output" == *"TLS Web Server Authentication"* ]]
  [[ "$output" == *"Authority Key Identifier"* ]]
  [[ "$output" == *"Subject Key Identifier"* ]]
  [[ "$output" == *"intermediate.crl"* ]]
  [[ "$output" == *"OCSP - URI:http://ocsp.kiln.test:2560"* ]]
}

@test "the chain verifies" {
  run verify.sh "$PKI_HOME/issued/web/cert.pem"
  [ "$status" -eq 0 ]
}

@test "a certificate fails against the wrong CA" {
  other="$(mktemp -d)"
  openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-384 -nodes -keyout "$other/k" -out "$other/ca.crt" -subj /CN=Other -days 2 2>/dev/null
  run openssl verify -CAfile "$other/ca.crt" -untrusted "$PKI_HOME/public/intermediate.crt" "$PKI_HOME/issued/web/cert.pem"
  rm -rf "$other"
  [ "$status" -ne 0 ]
}

@test "an expired certificate fails" {
  run verify.sh "$PKI_HOME/issued/old/cert.pem"
  [ "$status" -ne 0 ]
  [[ "$output" == *"expired"* ]]
}

@test "a revoked certificate fails the CRL check" {
  run verify.sh "$PKI_HOME/issued/bad/cert.pem" --crl
  [ "$status" -ne 0 ]
  [[ "$output" == *"revoked"* ]]
}

@test "a valid certificate passes the CRL check" {
  run verify.sh "$PKI_HOME/issued/web/cert.pem" --crl
  [ "$status" -eq 0 ]
}

@test "OCSP reports revoked for the revoked certificate" {
  run ocsp-check.sh "$PKI_HOME/issued/bad/cert.pem"
  [[ "$output" == *": revoked"* ]]
}

@test "OCSP reports good for a valid certificate" {
  run ocsp-check.sh "$PKI_HOME/issued/web/cert.pem"
  [[ "$output" == *": good"* ]]
}

@test "rotation gives a new serial and keeps the old certificate valid during overlap" {
  old_serial="$(openssl x509 -in "$PKI_HOME/issued/web/cert.pem" -noout -serial)"
  run rotate.sh web
  [ "$status" -eq 0 ]
  new_serial="$(openssl x509 -in "$PKI_HOME/issued/web/cert.pem" -noout -serial)"
  [ "$old_serial" != "$new_serial" ]
  run verify.sh "$PKI_HOME/issued/web/previous/cert.pem"
  [ "$status" -eq 0 ]
}

@test "expiry monitor flags certificates inside the warning window" {
  run expiry-monitor.sh 3650
  [ "$status" -eq 1 ]
  [[ "$output" == *"WARN"* ]]
  run expiry-monitor.sh 1
  [[ "$output" != *"WARN issued/web"* ]]
}
