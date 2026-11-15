include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

dependency "network" {
  config_path = "../shared-vpc"
  mock_outputs = {
    network_id    = "projects/kiln-host-prod/global/networks/kiln-shared-prod"
    subnetwork_id = "projects/kiln-service-prod/regions/us-central1/subnetworks/kiln-shared-prod"
  }
  mock_outputs_allowed_terraform_commands = ["validate"]
}

terraform {
  source = "${get_repo_root()}/modules/gcp/gke-private"
}

inputs = {
  project_id             = "kiln-service-prod"
  name                   = "kiln-private-prod"
  region                 = "us-central1"
  network                = dependency.network.outputs.network_id
  subnetwork             = dependency.network.outputs.subnetwork_id
  master_ipv4_cidr_block = "172.16.2.0/28"
  authorized_networks    = ["192.0.2.0/24"]
  labels                 = local.env.labels
}
