include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "${get_repo_root()}/modules/aws/state-bootstrap"
}

inputs = {
  bucket_name              = "kiln-state-bootstrap-prod"
  enforce_secure_transport = false
  tags                     = local.env.tags
}
