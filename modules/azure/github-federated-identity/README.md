# Azure GitHub federated identity

Creates a user-assigned managed identity and a federated credential locked to one GitHub repository and one branch or tag.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|---|---:|
| terraform | >= 1.11.0, < 2.0.0 |
| azurerm | = 5.12.0 |

## Inputs

| Name | Description |
|---|---|
| name | Managed identity name. |
| resource_group_name | Existing resource group name. |
| location | Azure region. |
| github_repository | GitHub owner and repository. |
| github_ref | Exact GitHub branch or tag ref. |
| tags | Resource tags. Environment, Owner and Project are required. |

## Outputs

| Name | Description |
|---|---|
| identity_id | Managed identity resource ID. |
| principal_id | Managed identity principal ID. |
<!-- END_TF_DOCS -->
