# GCP GitHub workload identity

Creates an OIDC pool and provider that require an exact GitHub repository and ref. The provider grants only the Workload Identity User role to the dedicated service account. It creates no key.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|---|---:|
| terraform | >= 1.11.0, < 2.0.0 |
| google | = 8.9.0 |

## Inputs

| Name | Description |
|---|---|
| project_id | Project that owns the pool. |
| pool_id | Workload identity pool identifier. |
| provider_id | OIDC provider identifier. |
| service_account_id | Service account ID to impersonate. |
| github_repository | GitHub owner and repository. |
| github_ref | Exact GitHub branch or tag ref. |

## Outputs

| Name | Description |
|---|---|
| pool_name | Workload identity pool resource name. |
| provider_name | GitHub OIDC provider resource name. |
| service_account_email | Federated service account email. |
<!-- END_TF_DOCS -->
