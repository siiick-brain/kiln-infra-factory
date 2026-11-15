variable "name" {
  type        = string
  description = "Name prefix for network resources."
  validation {
    condition     = can(regex("^[a-z0-9-]{1,40}$", var.name))
    error_message = "Name must use lowercase letters, digits and hyphens."
  }
}

variable "cidr_block" {
  type        = string
  description = "IPv4 CIDR range for the VPC."
  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "The VPC range must be a valid IPv4 CIDR block."
  }
}

variable "public_subnets" {
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))
  description = "Public subnet CIDRs and availability zones."
  default     = []
}

variable "private_subnets" {
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))
  description = "Private subnet CIDRs and availability zones."
  default     = []
}

variable "flow_logs_s3_arn" {
  type        = string
  description = "S3 destination ARN for VPC flow logs."
}

variable "ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "Explicit security group ingress rules."
  default     = []
}

variable "egress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "Explicit security group egress allow rules. Empty denies all egress."
  default     = []
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
