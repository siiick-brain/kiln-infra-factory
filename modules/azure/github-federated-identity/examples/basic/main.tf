provider "azurerm" {
  features {}
}

module "github_identity" {
  source = "../.."

  name                = "github-dev"
  resource_group_name = "rg-kiln-dev"
  location            = "eastus"
  github_repository   = "example/repository"
  github_ref          = "refs/heads/main"
  tags = {
    Environment = "dev"
    Owner       = "siiick-brain"
    Project     = "kiln-infra-factory"
  }
}
