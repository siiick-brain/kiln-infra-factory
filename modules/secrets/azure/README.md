# Azure Key Vault secret access

Assigns the built-in Key Vault Secrets User role to one principal at one existing secret scope. The module does not create or read secret values.

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
| [azurerm_role_assignment.secret_reader](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | Resource ID of an RBAC-enabled Key Vault. | `string` | n/a | yes |
| <a name="input_principal_id"></a> [principal\_id](#input\_principal\_id) | Object ID of the user, group or service principal receiving access. | `string` | n/a | yes |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | Name of the existing secret that receives the role assignment. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_role_assignment_id"></a> [role\_assignment\_id](#output\_role\_assignment\_id) | ID of the per-secret read-only role assignment. |
| <a name="output_scope"></a> [scope](#output\_scope) | Secret resource scope of the role assignment. |
<!-- END_TF_DOCS -->
