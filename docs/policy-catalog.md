# Terraform policy catalog

OPA evaluates AWS plan JSON. Conftest parses Azure and GCP Terraform HCL with the HCL2 parser. A denial is not a substitute for provider validation or a review of the planned change.

| Control | Denial condition | Test fixture |
|---|---|---|
| Required tags | Taggable resources lack non-empty Environment, Owner or Project tags or labels. | `fixtures/deny/required_tags.json` |
| SSH exposure | An ingress rule exposes port 22 or a range that includes it to `0.0.0.0/0`. | `fixtures/deny/open_ssh.json` and `fixtures/hcl/public-admin-port-ranges.tf` |
| RDP exposure | An ingress rule exposes port 3389 or a range that includes it to `0.0.0.0/0`. | `fixtures/deny/open_rdp.json` and `fixtures/hcl/public-admin-port-ranges.tf` |
| Public storage | An S3 public access block is incomplete or a GCS bucket does not enforce public access prevention. | `fixtures/deny/public_storage.json` |
| S3 encryption | An S3 bucket has no matching server-side encryption resource using AES256 or KMS. | `fixtures/deny/unencrypted_storage.json` |
| IAM actions | An IAM policy action contains a wildcard. | `fixtures/deny/wildcard_iam_action.json` |
| IAM resources | An IAM policy grants the unscoped `*` resource. | `fixtures/deny/wildcard_iam_resource.json` |
| OIDC subject | Federated AWS role trust does not include a `sub` condition. | `fixtures/deny/oidc_without_subject.json` |
| Private GKE nodes | A GKE cluster does not enable private nodes. | `fixtures/deny/public_gke_nodes.json` |
| GKE Workload Identity | A GKE cluster has no workload pool. | `fixtures/deny/gke_without_workload_identity.json` |
| Azure HTTPS | An App Service does not require HTTPS. | `fixtures/deny/azure_http.json` and `fixtures/hcl/azure-webapp-http.tf` |
| Azure TLS | An App Service permits a TLS version below 1.2. | `fixtures/deny/azure_old_tls.json` and `fixtures/hcl/azure-webapp-http.tf` |
| Static credentials | Terraform creates an AWS access key, GCP service account key or Azure service principal password. | `fixtures/deny/static_cloud_key.json` |
| Region allowlist | A resource declares a region outside the configured AWS, Azure and GCP allowlist. | `fixtures/deny/disallowed_region.json` |
| VPC flow logs | An AWS VPC plan has no flow log resource. | `fixtures/deny/vpc_without_flow_logs.json` |
| Production deletion protection | A supported database or cluster resource in prod has deletion protection disabled. | `fixtures/deny/prod_without_deletion_protection.json` |

Run the policy unit tests and the Azure and GCP HCL checks with:

```sh
opa test policies/terraform -v
conftest test --parser hcl2 --policy policies/terraform --namespace terraform modules/azure modules/gcp live
```

Policy limits:

- The tag rule applies only to resource types whose providers expose tags or labels. Some GCP network APIs do not expose those fields.
- SSH and RDP checks include port ranges and protocol rules with no port list. They do not model every provider-specific firewall feature.
- AWS log delivery needs a scoped log stream resource pattern ending in `:*`. The IAM rule rejects the unscoped `*` resource and rejects wildcard actions.
- GCP and Azure storage use provider-managed encryption defaults. AWS S3 encryption is checked as an explicit Terraform resource.
- The flow log rule checks for a planned flow log resource. It does not verify delivery.
- Production deletion protection is checked for the listed database and cluster resource types only.
