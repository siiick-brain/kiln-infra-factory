provider "azurerm" {
  features {}
  subscription_id = "00000000-0000-0000-0000-000000000001"
}

module "secret_access" {
  source = "../.."

  key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/example/providers/Microsoft.KeyVault/vaults/example"
  secret_name  = "application-database"
  principal_id = "00000000-0000-0000-0000-000000000002"
}
