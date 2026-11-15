include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "${get_repo_root()}/modules/azure/net-hub-spoke"
}

inputs = {
  name                = "stage-net"
  resource_group_name = "rg-kiln-stage"
  location            = "eastus"
  hub_address_space   = "10.11.0.0/16"
  spoke_address_space = "10.21.0.0/16"
  tags                = local.env.tags
}
