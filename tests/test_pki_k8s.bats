#!/usr/bin/env bats
# Kubernetes component certificates from the Kiln intermediate CA.
# The certificate list is informed by kubernetes-the-hard-way: API server, admin, kubelet,
# controller manager, scheduler, kube-proxy, etcd peer, etcd client and the service account key pair.

setup_file() {
  export REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  export PKI_HOME="$(mktemp -d)"
  export PATH="$REPO/pki/scripts:$PATH"
  ceremony.sh >/dev/null 2>&1
  k8s-certs.sh >"$PKI_HOME/k8s.log" 2>&1
}

teardown_file() {
  rm -rf "$PKI_HOME"
}

@test "every component certificate verifies against the Kiln chain" {
  for name in kube-apiserver admin kubelet-node-0 kube-controller-manager kube-scheduler kube-proxy etcd-peer-0 etcd-client; do
    run verify.sh "$PKI_HOME/issued/$name/cert.pem"
    [ "$status" -eq 0 ] || { echo "$name: $output"; return 1; }
  done
}

@test "API server certificate carries the service IP and cluster DNS names" {
  run openssl x509 -in "$PKI_HOME/issued/kube-apiserver/cert.pem" -noout -ext subjectAltName
  [[ "$output" == *"IP Address:10.32.0.1"* ]]
  [[ "$output" == *"DNS:kubernetes.default.svc.cluster.local"* ]]
  [[ "$output" == *"IP Address:127.0.0.1"* ]]
}

@test "admin certificate is in the system:masters group" {
  run openssl x509 -in "$PKI_HOME/issued/admin/cert.pem" -noout -subject
  [[ "$output" =~ O\ ?=\ ?system:masters ]]
  [[ "$output" =~ CN\ ?=\ ?admin ]]
}

@test "kubelet certificate uses the system:node identity and both EKUs" {
  run openssl x509 -in "$PKI_HOME/issued/kubelet-node-0/cert.pem" -noout -subject -ext extendedKeyUsage
  [[ "$output" =~ CN\ ?=\ ?system:node:node-0 ]]
  [[ "$output" =~ O\ ?=\ ?system:nodes ]]
  [[ "$output" == *"TLS Web Server Authentication"* ]]
  [[ "$output" == *"TLS Web Client Authentication"* ]]
}

@test "etcd peer certificate allows server and client authentication" {
  run openssl x509 -in "$PKI_HOME/issued/etcd-peer-0/cert.pem" -noout -ext extendedKeyUsage
  [[ "$output" == *"TLS Web Server Authentication"* ]]
  [[ "$output" == *"TLS Web Client Authentication"* ]]
}

@test "client-only certificates cannot act as servers" {
  run openssl x509 -in "$PKI_HOME/issued/etcd-client/cert.pem" -noout -ext extendedKeyUsage
  [[ "$output" != *"Server Authentication"* ]]
  run openssl verify -purpose sslserver -CAfile "$PKI_HOME/public/root.crt" -untrusted "$PKI_HOME/public/intermediate.crt" "$PKI_HOME/issued/admin/cert.pem"
  [ "$status" -ne 0 ]
}

@test "service account key pair matches" {
  pub_from_key="$(openssl pkey -in "$PKI_HOME/issued/service-account/key.pem" -pubout)"
  pub_file="$(cat "$PKI_HOME/issued/service-account/pub.pem")"
  [ "$pub_from_key" = "$pub_file" ]
}
