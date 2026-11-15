# Kubernetes with kind

`k8s/base` holds a sample workload for a local kind cluster. The manifests follow the same rules a GKE deployment from `modules/gcp/gke-private` would need.

## Manifests

| File | Content |
|------|---------|
| `namespace.yaml` | Namespace `kiln-demo` with Pod Security `restricted` labels for enforce, audit and warn |
| `serviceaccount.yaml` | ServiceAccount `web` with the `iam.gke.io/gcp-service-account` annotation for GKE workload identity and no token automount |
| `deployment.yaml` | Two replicas of nginx-unprivileged pinned by digest. uid 101, read-only root filesystem, no privilege escalation, all capabilities dropped, seccomp RuntimeDefault, CPU and memory requests and limits |
| `service.yaml` | ClusterIP service on port 80 to container port 8080 |
| `networkpolicy.yaml` | `default-deny` for all pods on ingress and egress, then one rule that allows port 8080 from pods in the same namespace |

On kind the workload identity annotation has no effect. It is checked by policy only.

## Checks

| Check | Command |
|-------|---------|
| Schema | `kubeconform -strict -summary -ignore-filename-pattern kustomization k8s/base` |
| Policy | `conftest test --policy policies/k8s --namespace k8s k8s/base/*.yaml` |
| Policy unit tests | `opa test policies/k8s` |
| Cluster | `docker compose --profile kind run --rm kind-runner bash k8s/kind-apply.sh` |

The Conftest rules in `policies/k8s/main.rego` deny containers that can run as root, have a writable root filesystem, allow privilege escalation, are privileged, keep capabilities, lack CPU or memory limits or use an image without a digest. They also deny host namespaces (hostNetwork, hostPID, hostIPC), a namespace without the `restricted` level, a ServiceAccount without the workload identity annotation and a `default-deny` policy that does not select every pod for both directions. The rules cover Deployment, StatefulSet, DaemonSet, ReplicaSet, Job, CronJob and Pod.

## The kind-runner trust decision

The `kind-runner` service mounts `/var/run/docker.sock`. Any process in that container controls the host Docker daemon, which is equivalent to root on the host. This is accepted for a local workstation only:

- The service sits behind the Compose profile `kind`, so `docker compose up` never starts it.
- It mounts the repository read-only.
- It is never used in CI.
- The kind node image and the runner base image are pinned by digest. kind and kubectl are verified against their published SHA-256 sums.

kindnet in kind 0.29 implements NetworkPolicy, but traffic blocking is not tested here. Enforcement is Not verified.

## Evidence

| Check | Result |
|-------|--------|
| kubeconform | 6 resources in 5 files valid, 0 invalid on 2026-11-15 |
| Conftest | 72 tests, 72 passed, 0 failures on 2026-11-15 |
| `opa test policies/k8s` | 12 of 12 passed on 2026-11-15 |
| kind | 7 PASS, 0 FAIL on 2026-11-15: both pods uid 101 with a read-only root filesystem, namespace enforces restricted, admission rejects a root pod, default-deny exists. Log `artifacts/logs/kind-apply.log` |
