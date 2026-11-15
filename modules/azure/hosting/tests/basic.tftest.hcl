mock_provider "azurerm" {}

run "requires_https_and_vnet_integration" {
  command = plan

  variables {
    name                       = "test-web"
    resource_group_name        = "rg-test"
    location                   = "eastus"
    integration_subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet/subnets/app"
    log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/logs"
    tags = {
      Environment = "test"
      Owner       = "siiick-brain"
      Project     = "kiln-infra-factory"
    }
  }

  assert {
    condition     = azurerm_linux_web_app.this.https_only
    error_message = "The app must require HTTPS."
  }

  assert {
    condition     = azurerm_linux_web_app.this.site_config[0].minimum_tls_version == "1.2"
    error_message = "The app must require TLS 1.2."
  }
}
