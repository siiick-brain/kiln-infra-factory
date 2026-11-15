output "web_app_id" {
  value       = azurerm_linux_web_app.this.id
  description = "Web app resource ID."
}

output "default_hostname" {
  value       = azurerm_linux_web_app.this.default_hostname
  description = "Web app hostname."
}

output "principal_id" {
  value       = azurerm_linux_web_app.this.identity[0].principal_id
  description = "System-assigned managed identity principal ID."
}
