locals {
  environment    = "dev"
  module_version = "0.1.0"
  tags = {
    Environment = "dev"
    Owner       = "siiick-brain"
    Project     = "kiln-infra-factory"
  }
  labels = {
    environment = "dev"
    owner       = "siiick-brain"
    project     = "kiln-infra-factory"
  }
}
