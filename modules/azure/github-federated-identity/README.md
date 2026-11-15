# Azure GitHub federated identity

Creates a user-assigned managed identity and a federated credential locked to one GitHub repository and one branch or tag.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | = 5.12.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 5.12.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_federated_identity_credential.github](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0/docs/resources/federated_identity_credential) | resource |
| [azurerm_user_assigned_identity.github](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0/docs/resources/user_assigned_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_github_ref"></a> [github\_ref](#input\_github\_ref) | Exact GitHub branch or tag ref. | `string` | n/a | yes |
| <a name="input_github_repository"></a> [github\_repository](#input\_github\_repository) | GitHub owner and repository. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Managed identity name. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Existing resource group name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags. Environment, Owner and Project are required. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_identity_id"></a> [identity\_id](#output\_identity\_id) | Managed identity resource ID. |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | Managed identity principal ID. |
<!-- END_TF_DOCS -->
