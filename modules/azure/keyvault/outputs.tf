output "key_vault_id" {
  value       = azurerm_key_vault.this.id
  description = "Key Vault resource ID."
}

output "vault_uri" {
  value       = azurerm_key_vault.this.vault_uri
  description = "Key Vault URI."
}
