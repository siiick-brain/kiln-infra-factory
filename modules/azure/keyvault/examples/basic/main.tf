provider "azurerm" {
  features {}
}

module "vault" {
  source = "../.."

  name                = "kiln-dev-vault"
  resource_group_name = "rg-kiln-dev"
  location            = "eastus"
  tenant_id           = "00000000-0000-0000-0000-000000000000"
  tags = {
    Environment = "dev"
    Owner       = "siiick-brain"
    Project     = "kiln-infra-factory"
  }
}
