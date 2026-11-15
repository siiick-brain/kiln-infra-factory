variable "project_id" {
  type        = string
  description = "GCP project ID."
}

variable "name" {
  type        = string
  description = "GKE cluster name."
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,38}[a-z0-9]$", var.name))
    error_message = "name must be a valid lowercase cluster name."
  }
}

variable "region" {
  type        = string
  description = "GKE region."
}

variable "network" {
  type        = string
  description = "Shared VPC network self-link."
}

variable "subnetwork" {
  type        = string
  description = "Shared VPC subnet self-link."
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "Private control plane CIDR."
  validation {
    condition     = can(cidrhost(var.master_ipv4_cidr_block, 0))
    error_message = "The control plane range must be a valid CIDR block."
  }
}

variable "authorized_networks" {
  type        = list(string)
  description = "CIDR ranges allowed to reach the private control plane."
  validation {
    condition     = length(var.authorized_networks) > 0 && alltrue([for range in var.authorized_networks : can(cidrhost(range, 0))])
    error_message = "At least one valid control plane CIDR is required."
  }
}

variable "network_tags" {
  type        = list(string)
  description = "Network tags for GKE nodes. The default matches the Shared VPC deny rules."
  default     = ["kiln-workload"]
  validation {
    condition     = length(var.network_tags) > 0 && contains(var.network_tags, "kiln-workload") && alltrue([for tag in var.network_tags : can(regex("^[a-z0-9-]{1,63}$", tag))])
    error_message = "network_tags must include kiln-workload and contain only valid network tags."
  }
}

variable "workload_identity_bindings" {
  type = list(object({
    service_account_email      = string
    namespace                  = string
    kubernetes_service_account = string
  }))
  description = "Google service accounts that exact Kubernetes service accounts may impersonate."
  default     = []
  validation {
    condition = alltrue([
      for binding in var.workload_identity_bindings :
      can(regex("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.iam\\.gserviceaccount\\.com$", binding.service_account_email)) &&
      can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", binding.namespace)) &&
      can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", binding.kubernetes_service_account))
    ])
    error_message = "Workload Identity bindings must use a Google service account email and valid Kubernetes names."
  }
}

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
