variable "name" {
  type        = string
  description = "Managed identity name."
}

variable "resource_group_name" {
  type        = string
  description = "Existing resource group name."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "github_repository" {
  type        = string
  description = "GitHub owner and repository."
  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", var.github_repository))
    error_message = "github_repository must be an owner/repository pair."
  }
}

variable "github_ref" {
  type        = string
  description = "Exact GitHub branch or tag ref."
  validation {
    condition     = can(regex("^refs/(heads|tags)/[A-Za-z0-9_./-]+$", var.github_ref)) && !strcontains(var.github_ref, "*")
    error_message = "github_ref must be a specific branch or tag ref without wildcards."
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
