include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "${get_repo_root()}/modules/gcp/shared-vpc"
}

inputs = {
  host_project_id        = "kiln-host-dev"
  service_project_id     = "kiln-service-dev"
  service_project_number = "123456789012"
  network_name           = "kiln-shared-dev"
  region                 = "us-central1"
  subnet_cidr            = "10.60.0.0/20"
  labels                 = local.env.labels
}
