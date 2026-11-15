# GCP Secret Manager access

Grants the Secret Manager Secret Accessor role to one specific principal on one secret. The module does not create or read secret values.

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
| [google_secret_manager_secret_iam_member.accessor](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/secret_manager_secret_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_member"></a> [member](#input\_member) | Specific IAM principal receiving secret accessor access. | `string` | n/a | yes |
| <a name="input_secret_id"></a> [secret\_id](#input\_secret\_id) | Full resource name of one existing Secret Manager secret. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_iam_member_id"></a> [iam\_member\_id](#output\_iam\_member\_id) | ID of the secret-scoped accessor binding. |
| <a name="output_secret_id"></a> [secret\_id](#output\_secret\_id) | Secret resource receiving the binding. |
<!-- END_TF_DOCS -->
