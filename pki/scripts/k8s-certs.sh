#!/usr/bin/env bash
# Issues the certificates a small Kubernetes control plane needs from the Kiln intermediate CA.
# The list is informed by kubernetes-the-hard-way. Names, subjects and SANs are this project's own.
set -euo pipefail
# shellcheck source=pki/scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  echo "Usage: k8s-certs.sh [node-name] [node-ip]" >&2
  echo "Defaults: node-0 10.240.0.20. Writes under PKI_HOME/issued/." >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

node="${1:-node-0}"
node_ip="${2:-10.240.0.20}"
service_ip="10.32.0.1"
controller_ip="10.240.0.10"
none="DNS:unused.invalid"

issue_one() {
  local name="$1" cn="$2" org="$3" san="$4" profile="$5"
  "$SCRIPT_DIR/csr.sh" "$name" "$cn" "$san" "$org" >/dev/null
  "$SCRIPT_DIR/issue.sh" "$name" "$profile" 365
}

apiserver_san="IP:$service_ip,IP:$controller_ip,IP:127.0.0.1,DNS:kubernetes,DNS:kubernetes.default"
apiserver_san="$apiserver_san,DNS:kubernetes.default.svc,DNS:kubernetes.default.svc.cluster,DNS:kubernetes.default.svc.cluster.local"

issue_one kube-apiserver kubernetes Kubernetes "$apiserver_san" kube_apiserver
issue_one admin admin system:masters "$none" kube_client
issue_one "kubelet-$node" "system:node:$node" system:nodes "DNS:$node,IP:$node_ip" kubelet_serving
issue_one kube-controller-manager system:kube-controller-manager system:kube-controller-manager "$none" kube_client
issue_one kube-scheduler system:kube-scheduler system:kube-scheduler "$none" kube_client
issue_one kube-proxy system:kube-proxy system:node-proxier "$none" kube_client
issue_one etcd-peer-0 etcd-0 Kubernetes "DNS:etcd-0,IP:$controller_ip,IP:127.0.0.1" etcd_peer
issue_one etcd-client kube-apiserver-etcd-client Kubernetes "$none" etcd_client

# The service account key pair signs and verifies service account tokens. It is not a certificate.
sa_dir="$PKI_ISSUED_DIR/service-account"
mkdir -p "$sa_dir"
umask 077
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out "$sa_dir/key.pem"
umask 022
openssl pkey -in "$sa_dir/key.pem" -pubout -out "$sa_dir/pub.pem"
echo "ISSUED service-account key pair"
