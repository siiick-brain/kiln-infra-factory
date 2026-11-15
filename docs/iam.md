# Workload identity and IAM

The identity modules use short-lived federation rather than long-lived cloud keys. Trust is restricted to an exact repository and branch or tag reference. Wildcards are rejected for AWS IAM actions and resource ARNs.

## GitHub Actions federation

| Module | Trust control | Permissions created by the module |
|---|---|---|
| AWS `github-oidc` | OIDC `sub` must match `repo:<owner>/<repository>:ref:<ref>` and audience must be `sts.amazonaws.com`. | The role policy contains only caller-supplied actions and exact resource ARNs. Both sets must be non-empty and cannot contain `*`. |
| Azure `github-federated-identity` | Federated credential subject must match the exact repository and ref. | Creates a user-assigned managed identity and its federated credential. It assigns no Azure roles. |
| GCP `workload-identity-federation` | Provider condition matches the exact GitHub repository and ref. | Creates a workload identity user binding for the federated principal. It grants no project roles to the created service account. |

Cloud resource permissions must be granted separately to the federated identity. Grant only the actions and resources required by the workflow. No workflow in this repository uses a cloud credential.

## GKE identity

The GKE module enables the cluster workload identity pool and binds only the configured Kubernetes namespace and service account to each named Google service account. Each binding uses `roles/iam.workloadIdentityUser`. The module does not grant application permissions to those Google service accounts.

The node service account receives `roles/logging.logWriter` and `roles/monitoring.metricWriter` at project scope for node telemetry. The node pool uses the `cloud-platform` OAuth scope, which does not itself grant IAM permissions. IAM roles on the node service account define the effective permissions.

Do not bind application workloads to the node service account. Create a separate Google service account for each workload permission boundary and grant it only the roles the workload needs.

## Verification

Mock-provider tests assert exact repository and ref conditions, the GKE namespace/service-account subject and the fixed node roles. AWS module tests reject wildcard actions and resource ARNs. OPA and Conftest checks reject wildcard IAM actions and unscoped wildcard IAM resources in evaluated policies.

These tests verify Terraform configuration and policy inputs. They do not prove that a real cloud identity provider accepts a token or that permissions are sufficient for a deployed workflow.
