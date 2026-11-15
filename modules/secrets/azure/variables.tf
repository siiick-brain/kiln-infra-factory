variable "key_vault_id" {
  type        = string
  description = "Resource ID of an RBAC-enabled Key Vault."
  validation {
    condition     = can(regex("^/subscriptions/[0-9a-fA-F-]{36}/resourceGroups/[^/]+/providers/Microsoft.KeyVault/vaults/[^/]+$", var.key_vault_id))
    error_message = "key_vault_id must be a Key Vault resource ID."
  }
}

variable "secret_name" {
  type        = string
  description = "Name of the existing secret that receives the role assignment."
  validation {
    condition     = can(regex("^[A-Za-z0-9-]{1,127}$", var.secret_name))
    error_message = "secret_name must contain 1 to 127 letters, digits or hyphens."
  }
}

variable "principal_id" {
  type        = string
  description = "Object ID of the user, group or service principal receiving access."
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$", var.principal_id))
    error_message = "principal_id must be a UUID."
  }
}
