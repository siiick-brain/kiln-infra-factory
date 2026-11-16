#!/usr/bin/env bash
# Creates a local kind cluster, applies k8s/base and checks that the pods run as non-root
# with a read-only root filesystem. Runs inside the kind-runner container only.
set -euo pipefail

usage() {
  echo "Usage: k8s/kind-apply.sh [--delete]" >&2
  echo "Run with: docker compose --profile kind run --rm kind-runner bash k8s/kind-apply.sh" >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

cluster="kiln"
node_image="kindest/node:v1.33.1@sha256:050072256b9a903bd914c0b2866828150cb229cea0efe5892e2b644d5dd3b34f"
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export KUBECONFIG=/tmp/kiln-kubeconfig

if [[ "${1:-}" == "--delete" ]]; then
  kind delete cluster --name "$cluster"
  exit 0
fi

if ! kind get clusters 2>/dev/null | grep -qx "$cluster"; then
  kind create cluster --name "$cluster" --image "$node_image" --wait 120s
fi
# The runner reaches the API server over the kind network with the internal kubeconfig.
docker network connect kind "$(hostname)" 2>/dev/null || true
kind get kubeconfig --name "$cluster" --internal >"$KUBECONFIG"

kubectl apply -k "$repo/k8s/base"
kubectl -n kiln-demo rollout status deployment/web --timeout=180s

failed=0
check() {
  if [[ "$2" == "ok" ]]; then echo "PASS $1"; else
    echo "FAIL $1: $2"
    failed=$((failed + 1))
  fi
}

pods="$(kubectl -n kiln-demo get pods -l app=web -o jsonpath='{.items[*].metadata.name}')"
for pod in $pods; do
  uid="$(kubectl -n kiln-demo exec "$pod" -- id -u)"
  [[ "$uid" != "0" ]] && r=ok || r="uid 0"
  check "$pod runs as non-root (uid $uid)" "$r"
  if kubectl -n kiln-demo exec "$pod" -- sh -c 'touch /probe' 2>/dev/null; then
    r="root filesystem is writable"
  else
    r=ok
  fi
  check "$pod has a read-only root filesystem" "$r"
done

ns_label="$(kubectl get ns kiln-demo -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}')"
[[ "$ns_label" == "restricted" ]] && r=ok || r="label $ns_label"
check "namespace enforces Pod Security restricted" "$r"

if kubectl -n kiln-demo run root-probe --image=busybox:1.37 --restart=Never --dry-run=server \
  --overrides='{"spec":{"securityContext":{"runAsUser":0}}}' >/dev/null 2>&1; then
  r="a root pod was admitted"
else
  r=ok
fi
check "Pod Security admission rejects a root pod" "$r"

kubectl get networkpolicy -n kiln-demo default-deny >/dev/null && r=ok || r="missing"
check "default-deny NetworkPolicy exists" "$r"

echo "kind: $failed failed"
((failed == 0))
