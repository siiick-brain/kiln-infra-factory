# GCP GitHub workload identity

Creates an OIDC pool and provider that require an exact GitHub repository and ref. The provider grants only the Workload Identity User role to the dedicated service account. It creates no key.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | = 8.9.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | 8.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_iam_workload_identity_pool.github](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/iam_workload_identity_pool) | resource |
| [google_iam_workload_identity_pool_provider.github](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/iam_workload_identity_pool_provider) | resource |
| [google_service_account.github](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/service_account) | resource |
| [google_service_account_iam_member.federated](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/service_account_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_github_ref"></a> [github\_ref](#input\_github\_ref) | Exact GitHub branch or tag ref. | `string` | n/a | yes |
| <a name="input_github_repository"></a> [github\_repository](#input\_github\_repository) | GitHub owner and repository. | `string` | n/a | yes |
| <a name="input_pool_id"></a> [pool\_id](#input\_pool\_id) | Workload identity pool identifier. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project that owns the workload identity pool. | `string` | n/a | yes |
| <a name="input_provider_id"></a> [provider\_id](#input\_provider\_id) | OIDC provider identifier. | `string` | n/a | yes |
| <a name="input_service_account_id"></a> [service\_account\_id](#input\_service\_account\_id) | Service account ID to impersonate. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_pool_name"></a> [pool\_name](#output\_pool\_name) | Workload identity pool resource name. |
| <a name="output_provider_name"></a> [provider\_name](#output\_provider\_name) | GitHub OIDC provider resource name. |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | Federated service account email. |
<!-- END_TF_DOCS -->
