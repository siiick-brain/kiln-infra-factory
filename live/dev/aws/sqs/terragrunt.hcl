include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "${get_repo_root()}/modules/aws/sqs"
}

inputs = {
  name                        = "dev-events"
  enable_redrive_allow_policy = false
  tags                        = local.env.tags
}
