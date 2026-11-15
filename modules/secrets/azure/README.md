# Azure Key Vault secret access

Assigns the built-in Key Vault Secrets User role to one principal at one existing secret scope. The module does not create or read secret values.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|---|---:|
| terraform | >= 1.11.0, < 2.0.0 |
| azurerm | = 5.12.0 |

## Inputs

| Name | Description |
|---|---|
| key_vault_id | Resource ID of an RBAC-enabled Key Vault. |
| secret_name | Name of the existing secret that receives the role assignment. |
| principal_id | Object ID of the principal receiving access. |

## Outputs

| Name | Description |
|---|---|
| role_assignment_id | ID of the per-secret read-only role assignment. |
| scope | Secret resource scope of the role assignment. |
<!-- END_TF_DOCS -->
