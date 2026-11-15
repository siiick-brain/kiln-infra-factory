variable "name" {
  type        = string
  description = "Web app name."
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{2,60}$", var.name))
    error_message = "Name must contain 2 to 60 letters, digits or hyphens."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Existing resource group name."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "integration_subnet_id" {
  type        = string
  description = "Subnet delegated for App Service VNet integration."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace for diagnostics."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags. Environment, Owner and Project are required."
  validation {
    condition = alltrue([
      for key in ["Environment", "Owner", "Project"] :
      contains(keys(var.tags), key) && length(trimspace(lookup(var.tags, key, ""))) > 0
    ])
    error_message = "Tags must include non-empty Environment, Owner and Project values."
  }
}
