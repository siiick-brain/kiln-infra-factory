output "role_assignment_id" {
  value       = azurerm_role_assignment.secret_reader.id
  description = "ID of the per-secret read-only role assignment."
}

output "scope" {
  value       = azurerm_role_assignment.secret_reader.scope
  description = "Secret resource scope of the role assignment."
}
