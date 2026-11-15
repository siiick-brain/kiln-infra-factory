variable "name" {
  type        = string
  description = "Queue name."
  validation {
    condition     = can(regex("^[A-Za-z0-9_-]{1,75}$", var.name))
    error_message = "Queue name must contain only letters, digits, hyphens or underscores."
  }
}

variable "max_receive_count" {
  type        = number
  description = "Receive count before a message moves to the dead-letter queue."
  default     = 5
  validation {
    condition     = var.max_receive_count >= 1 && var.max_receive_count <= 1000
    error_message = "max_receive_count must be between 1 and 1000."
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
