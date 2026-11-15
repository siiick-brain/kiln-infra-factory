output "identity_id" {
  value       = azurerm_user_assigned_identity.github.id
  description = "Managed identity resource ID."
}

output "principal_id" {
  value       = azurerm_user_assigned_identity.github.principal_id
  description = "Managed identity principal ID."
}
