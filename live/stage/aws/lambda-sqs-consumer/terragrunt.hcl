include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

terraform {
  source = "${get_repo_root()}/modules/aws/lambda-sqs-consumer"
}

inputs = {
  function_name        = "stage-consumer"
  reserved_concurrency = 3
  # Moto does not return RedriveAllowPolicy, so Terraform would wait for it. See ADR 0001.
  enable_redrive_allow_policy = !local.env.emulator
  tags                        = local.env.tags
}
