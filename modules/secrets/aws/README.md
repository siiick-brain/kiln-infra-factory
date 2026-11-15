# AWS Secrets Manager access

Attaches an inline policy to an existing role. The policy grants only `DescribeSecret` and `GetSecretValue` for one supplied secret ARN. Secret values are not managed by this module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | = 6.71.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.71.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_role_policy.secret_access](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/iam_role_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Existing IAM role to receive the inline policy. | `string` | n/a | yes |
| <a name="input_secret_arn"></a> [secret\_arn](#input\_secret\_arn) | ARN of the single Secrets Manager secret this role may read. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_policy_id"></a> [policy\_id](#output\_policy\_id) | ID of the inline secret access policy. |
| <a name="output_policy_json"></a> [policy\_json](#output\_policy\_json) | Read-only policy scoped to the supplied secret ARN. |
<!-- END_TF_DOCS -->
