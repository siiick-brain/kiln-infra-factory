variable "name" {
  type        = string
  description = "Network name prefix."
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{2,40}$", var.name))
    error_message = "Name must contain 2 to 40 letters, digits or hyphens."
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

variable "hub_address_space" {
  type        = string
  description = "Hub virtual network CIDR."
  validation {
    condition     = can(cidrhost(var.hub_address_space, 0))
    error_message = "Hub address space must be a valid CIDR block."
  }
}

variable "spoke_address_space" {
  type        = string
  description = "Spoke virtual network CIDR."
  validation {
    condition     = can(cidrhost(var.spoke_address_space, 0))
    error_message = "Spoke address space must be a valid CIDR block."
  }
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
