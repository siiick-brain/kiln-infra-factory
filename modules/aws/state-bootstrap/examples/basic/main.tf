module "state" {
  source = "../.."

  bucket_name = "kiln-infra-factory-dev-state"
  tags = {
    Environment = "dev"
    Owner       = "siiick-brain"
    Project     = "kiln-infra-factory"
  }
}
