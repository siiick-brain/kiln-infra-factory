# AWS Secrets Manager access

Attaches an inline policy to an existing role. The policy grants only `DescribeSecret` and `GetSecretValue` for one supplied secret ARN. Secret values are not managed by this module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|---|---:|
| terraform | >= 1.11.0, < 2.0.0 |
| aws | = 6.71.0 |

## Inputs

| Name | Description |
|---|---|
| role_name | Existing IAM role to receive the inline policy. |
| secret_arn | ARN of the single Secrets Manager secret this role may read. |

## Outputs

| Name | Description |
|---|---|
| policy_id | ID of the inline secret access policy. |
| policy_json | Read-only policy scoped to the supplied secret ARN. |
<!-- END_TF_DOCS -->
