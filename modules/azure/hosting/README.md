# Azure hosting

Creates a Linux App Service with VNet integration, a system-assigned identity, HTTPS-only access, TLS 1.2 minimum and diagnostic settings. The example uses fake identifiers.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|---|---:|
| terraform | >= 1.11.0, < 2.0.0 |
| azurerm | = 5.12.0 |

## Inputs

| Name | Description |
|---|---|
| name | Web app name. |
| resource_group_name | Existing resource group name. |
| location | Azure region. |
| integration_subnet_id | Subnet delegated for App Service VNet integration. |
| log_analytics_workspace_id | Log Analytics workspace for diagnostics. |
| tags | Resource tags. Environment, Owner and Project are required. |

## Outputs

| Name | Description |
|---|---|
| web_app_id | Web app resource ID. |
| default_hostname | Web app hostname. |
| principal_id | System-assigned managed identity principal ID. |
<!-- END_TF_DOCS -->
