mock_provider "azurerm" {}

run "assigns_secret_reader_at_secret_scope" {
  command = plan

  variables {
    key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/example/providers/Microsoft.KeyVault/vaults/example"
    secret_name  = "application-database"
    principal_id = "00000000-0000-0000-0000-000000000002"
  }

  assert {
    condition     = azurerm_role_assignment.secret_reader.scope == "${var.key_vault_id}/secrets/${var.secret_name}"
    error_message = "The role assignment must be scoped to the requested secret."
  }

  assert {
    condition     = azurerm_role_assignment.secret_reader.role_definition_name == "Key Vault Secrets User"
    error_message = "The role assignment must use the read-only secret role."
  }
}
