provider "azurerm" {
  features {}
}

module "network" {
  source = "../.."

  name                = "dev-net"
  resource_group_name = "rg-kiln-dev"
  location            = "eastus"
  hub_address_space   = "10.10.0.0/16"
  spoke_address_space = "10.20.0.0/16"
  tags = {
    Environment = "dev"
    Owner       = "siiick-brain"
    Project     = "kiln-infra-factory"
  }
}
