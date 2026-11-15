include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

dependency "state" {
  config_path = "../state-bootstrap"
  mock_outputs = {
    bucket_arn = "arn:aws:s3:::kiln-state-bootstrap-stage"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "${get_repo_root()}/modules/aws/net"
}

inputs = {
  name       = "stage-network"
  cidr_block = "10.30.0.0/16"
  public_subnets = [{
    cidr_block        = "10.30.1.0/24"
    availability_zone = "us-east-1a"
  }]
  private_subnets = [{
    cidr_block        = "10.30.11.0/24"
    availability_zone = "us-east-1a"
  }]
  flow_logs_s3_arn = dependency.state.outputs.bucket_arn
  tags             = local.env.tags
}
