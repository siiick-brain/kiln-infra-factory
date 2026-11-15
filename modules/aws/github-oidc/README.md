# AWS GitHub OIDC

Creates a GitHub Actions OIDC provider and a role whose trust is locked to one repository and one branch or tag. The inline policy requires explicit actions and resource ARNs without wildcards.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|---|---:|
| terraform | >= 1.11.0, < 2.0.0 |
| aws | = 6.71.0 |

## Inputs

| Name | Description |
|---|---|
| github_repository | GitHub owner and repository. |
| github_ref | Exact allowed branch or tag reference. |
| allowed_actions | Explicit IAM actions. |
| resource_arns | Exact resource ARNs. |
| tags | Resource tags. Environment, Owner and Project are required. |

## Outputs

| Name | Description |
|---|---|
| role_arn | GitHub Actions role ARN. |
| provider_arn | GitHub OIDC provider ARN. |
<!-- END_TF_DOCS -->
