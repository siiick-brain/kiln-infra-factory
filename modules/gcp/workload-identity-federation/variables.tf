variable "project_id" {
  type        = string
  description = "Project that owns the workload identity pool."
}

variable "pool_id" {
  type        = string
  description = "Workload identity pool identifier."
  validation {
    condition     = can(regex("^[a-z0-9-]{4,32}$", var.pool_id))
    error_message = "pool_id must contain 4 to 32 lowercase letters, digits or hyphens."
  }
}

variable "provider_id" {
  type        = string
  description = "OIDC provider identifier."
}

variable "service_account_id" {
  type        = string
  description = "Service account ID to impersonate."
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.service_account_id))
    error_message = "service_account_id must be a valid lowercase service account ID."
  }
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
