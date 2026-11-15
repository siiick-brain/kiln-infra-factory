variable "function_name" {
  type        = string
  description = "Function and queue name prefix."
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]{1,48}$", var.function_name))
    error_message = "Function name must use letters, digits, hyphens or underscores."
  }
}

variable "reserved_concurrency" {
  type        = number
  description = "Maximum concurrent function executions."
  default     = 5
  validation {
    condition     = var.reserved_concurrency >= 1 && var.reserved_concurrency <= 1000
    error_message = "reserved_concurrency must be between 1 and 1000."
  }
}

variable "enable_redrive_allow_policy" {
  type        = bool
  description = "Whether to restrict the DLQ source queue. Disable only for emulators that cannot read this attribute."
  default     = true
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
