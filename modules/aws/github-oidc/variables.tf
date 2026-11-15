variable "github_repository" {
  type        = string
  description = "GitHub owner and repository, for example owner/repository."
  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", var.github_repository))
    error_message = "github_repository must be an owner/repository pair."
  }
}

variable "github_ref" {
  type        = string
  description = "Exact Git ref allowed to assume the role."
  validation {
    condition     = can(regex("^refs/(heads|tags)/[A-Za-z0-9_./-]+$", var.github_ref)) && !strcontains(var.github_ref, "*")
    error_message = "github_ref must be a specific branch or tag ref without wildcards."
  }
}

variable "allowed_actions" {
  type        = set(string)
  description = "Explicit IAM actions allowed for the federated role."
  validation {
    condition     = length(var.allowed_actions) > 0 && alltrue([for action in var.allowed_actions : !strcontains(action, "*")])
    error_message = "IAM actions must be non-empty and must not contain wildcards."
  }
}

variable "resource_arns" {
  type        = set(string)
  description = "Exact resource ARNs allowed for the federated role."
  validation {
    condition     = length(var.resource_arns) > 0 && alltrue([for arn in var.resource_arns : !strcontains(arn, "*")])
    error_message = "Resource ARNs must be non-empty and must not contain wildcards."
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
