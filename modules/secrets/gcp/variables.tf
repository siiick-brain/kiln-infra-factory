variable "secret_id" {
  type        = string
  description = "Full resource name of one existing Secret Manager secret."
  validation {
    condition     = can(regex("^projects/[^/]+/secrets/[^/]+$", var.secret_id))
    error_message = "secret_id must identify one Secret Manager secret."
  }
}

variable "member" {
  type        = string
  description = "Specific IAM principal receiving secret accessor access."
  validation {
    condition     = can(regex("^(serviceAccount|user|group|principal|principalSet):[^*]+$", var.member)) && !contains(["allUsers", "allAuthenticatedUsers"], var.member)
    error_message = "member must identify a specific principal and must not contain a wildcard."
  }
}
