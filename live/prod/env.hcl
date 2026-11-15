locals {
  environment    = "prod"
  module_version = "0.1.0"
  tags = {
    Environment = "prod"
    Owner       = "siiick-brain"
    Project     = "kiln-infra-factory"
  }
  labels = {
    environment = "prod"
    owner       = "siiick-brain"
    project     = "kiln-infra-factory"
  }
}
