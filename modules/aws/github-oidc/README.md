# AWS GitHub OIDC

Creates a GitHub Actions OIDC provider and a role whose trust is locked to one repository and one branch or tag. The inline policy requires explicit actions and resource ARNs without wildcards.

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
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.github](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.github](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/iam_role_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_allowed_actions"></a> [allowed\_actions](#input\_allowed\_actions) | Explicit IAM actions allowed for the federated role. | `set(string)` | n/a | yes |
| <a name="input_github_ref"></a> [github\_ref](#input\_github\_ref) | Exact Git ref allowed to assume the role. | `string` | n/a | yes |
| <a name="input_github_repository"></a> [github\_repository](#input\_github\_repository) | GitHub owner and repository, for example owner/repository. | `string` | n/a | yes |
| <a name="input_resource_arns"></a> [resource\_arns](#input\_resource\_arns) | Exact resource ARNs allowed for the federated role. | `set(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags. Environment, Owner and Project are required. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_provider_arn"></a> [provider\_arn](#output\_provider\_arn) | GitHub OIDC provider ARN. |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | GitHub Actions role ARN. |
<!-- END_TF_DOCS -->
