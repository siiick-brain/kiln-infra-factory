variable "project_id" {
  type        = string
  description = "Project whose logs are exported."
}

variable "name" {
  type        = string
  description = "Log export prefix."
}

variable "region" {
  type        = string
  description = "Cloud Storage bucket region."
}

variable "filter" {
  type        = string
  description = "Required filter for both project sinks."
  validation {
    condition     = length(trimspace(var.filter)) > 0
    error_message = "The sink filter must not be empty."
  }
}

variable "exclusions" {
  type = list(object({
    name   = string
    filter = string
  }))
  description = "Explicit log exclusions applied to both sinks."
  default     = []
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
