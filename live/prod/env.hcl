locals {
  environment    = "prod"
  module_version = "0.1.0"
  # Every unit targets the Moto emulator (root.hcl endpoints). Set false for a real account.
  emulator = true
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
