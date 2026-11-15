locals {
  path_parts = split("/", replace(path_relative_to_include(), "\\", "/"))
  cloud      = try(local.path_parts[2], "aws")
  aws_provider = <<-EOF
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "testing"
  secret_key                  = "testing"
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_region_validation      = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  endpoints {
    ec2    = "http://emulator:5000"
    iam    = "http://emulator:5000"
    lambda = "http://emulator:5000"
    logs   = "http://emulator:5000"
    s3     = "http://emulator:5000"
    sqs    = "http://emulator:5000"
    sts    = "http://emulator:5000"
  }
}
EOF
  azure_provider = <<-EOF
provider "azurerm" {
  features {}
}
EOF
  google_provider = <<-EOF
provider "google" {
  project = "kiln-mock-project"
  region  = "us-central1"
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    bucket                      = "kiln-infra-state"
    key                         = "${path_relative_to_include()}/terraform.tfstate"
    region                      = "us-east-1"
    endpoints                   = { s3 = "http://emulator:5000" }
    use_path_style              = true
    use_lockfile                = true
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    access_key                  = "testing"
    secret_key                  = "testing"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = local.cloud == "azure" ? local.azure_provider : local.cloud == "gcp" ? local.google_provider : local.aws_provider
}
