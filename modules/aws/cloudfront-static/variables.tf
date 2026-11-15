variable "bucket_name" {
  type        = string
  description = "Private S3 origin bucket name."
}

variable "logging_bucket_domain_name" {
  type        = string
  description = "S3 bucket domain for CloudFront access logs."
}

variable "aliases" {
  type        = list(string)
  description = "Optional DNS names for the distribution."
  default     = []
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN in us-east-1 when aliases are configured."
  default     = null
  validation {
    condition     = var.certificate_arn == null || startswith(var.certificate_arn, "arn:")
    error_message = "certificate_arn must be an ARN or null."
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
