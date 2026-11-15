variable "role_name" {
  type        = string
  description = "Existing IAM role to receive the inline policy."
  validation {
    condition     = can(regex("^[A-Za-z0-9+=,.@_-]{1,64}$", var.role_name))
    error_message = "role_name must be a valid IAM role name."
  }
}

variable "secret_arn" {
  type        = string
  description = "ARN of the single Secrets Manager secret this role may read."
  validation {
    condition     = can(regex("^arn:[^:]+:secretsmanager:[^:]+:[0-9]{12}:secret:.+$", var.secret_arn))
    error_message = "secret_arn must identify one Secrets Manager secret."
  }
}
