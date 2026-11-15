resource "azurerm_role_assignment" "secret_reader" {
  scope                = "${var.key_vault_id}/secrets/${var.secret_name}"
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.principal_id
}
