variable "bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for Terraform state."
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must use lowercase DNS-compatible characters."
  }
}

variable "enforce_secure_transport" {
  type        = bool
  description = "Deny unencrypted transport. Disable only for the local HTTP emulator."
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
