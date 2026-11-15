mock_provider "azurerm" {}

run "blocks_public_access_and_enables_protection" {
  command = plan

  variables {
    name                = "kiln-test-vault"
    resource_group_name = "rg-test"
    location            = "eastus"
    tenant_id           = "00000000-0000-0000-0000-000000000000"
    tags = {
      Environment = "test"
      Owner       = "siiick-brain"
      Project     = "kiln-infra-factory"
    }
  }

  assert {
    condition     = azurerm_key_vault.this.public_network_access_enabled == false
    error_message = "Public network access must be disabled."
  }

  assert {
    condition     = azurerm_key_vault.this.purge_protection_enabled
    error_message = "Purge protection must be enabled."
  }
}
