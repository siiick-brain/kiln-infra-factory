variable "host_project_id" {
  type        = string
  description = "Host project ID."
}

variable "service_project_id" {
  type        = string
  description = "Attached service project ID."
}

variable "service_project_number" {
  type        = string
  description = "Numeric service project ID for the Shared VPC service agent."
  validation {
    condition     = can(regex("^[0-9]+$", var.service_project_number))
    error_message = "service_project_number must contain only digits."
  }
}

variable "network_name" {
  type        = string
  description = "Shared VPC network name."
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,61}[a-z0-9]$", var.network_name))
    error_message = "network_name must be a valid lowercase network name."
  }
}

variable "region" {
  type        = string
  description = "Region for the subnet and Cloud NAT."
}

variable "subnet_cidr" {
  type        = string
  description = "IPv4 CIDR range for the service subnet."
  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "subnet_cidr must be a valid CIDR block."
  }
}

variable "network_tags" {
  type        = list(string)
  description = "Instance tags targeted by default-deny firewall rules."
  default     = ["kiln-workload"]
  validation {
    condition     = length(var.network_tags) > 0 && contains(var.network_tags, "kiln-workload") && alltrue([for tag in var.network_tags : can(regex("^[a-z0-9-]{1,63}$", tag))])
    error_message = "network_tags must include kiln-workload and contain only valid network tags."
  }
}

# Compute networks, subnets and firewall rules do not accept labels. The variable stays so the
# required label validation still applies to every caller, as in the other modules.
# tflint-ignore: terraform_unused_declarations
variable "labels" {
  type        = map(string)
  description = "Resource labels. environment, owner and project are required."
  validation {
    condition = alltrue([
      for key in ["environment", "owner", "project"] :
      contains(keys(var.labels), key) && length(trimspace(lookup(var.labels, key, ""))) > 0
    ])
    error_message = "Labels must include non-empty environment, owner and project values."
  }
}
