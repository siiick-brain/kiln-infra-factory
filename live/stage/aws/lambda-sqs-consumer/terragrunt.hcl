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
  tags                 = local.env.tags
}
