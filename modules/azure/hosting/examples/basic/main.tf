provider "azurerm" {
  features {}
}

module "hosting" {
  source = "../.."

  name                       = "dev-web"
  resource_group_name        = "rg-kiln-dev"
  location                   = "eastus"
  integration_subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-kiln-dev/providers/Microsoft.Network/virtualNetworks/dev-spoke/subnets/app"
  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-kiln-dev/providers/Microsoft.OperationalInsights/workspaces/dev-logs"
  tags = {
    Environment = "dev"
    Owner       = "siiick-brain"
    Project     = "kiln-infra-factory"
  }
}
