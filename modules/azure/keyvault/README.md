# Azure Key Vault

Creates a private, RBAC-enabled Key Vault with purge protection and soft delete. No secret values are stored by this module. Configure a private endpoint before use from a network.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|---|---:|
| terraform | >= 1.11.0, < 2.0.0 |
| azurerm | = 5.12.0 |

## Inputs

| Name | Description |
|---|---|
| name | Globally unique Key Vault name. |
| resource_group_name | Existing resource group name. |
| location | Azure region. |
| tenant_id | Azure tenant ID. |
| tags | Resource tags. Environment, Owner and Project are required. |

## Outputs

| Name | Description |
|---|---|
| key_vault_id | Key Vault resource ID. |
| vault_uri | Key Vault URI. |
<!-- END_TF_DOCS -->
