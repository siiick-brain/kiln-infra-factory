locals {
  environment    = "stage"
  module_version = "0.1.0"
  tags = {
    Environment = "stage"
    Owner       = "siiick-brain"
    Project     = "kiln-infra-factory"
  }
  labels = {
    environment = "stage"
    owner       = "siiick-brain"
    project     = "kiln-infra-factory"
  }
}
