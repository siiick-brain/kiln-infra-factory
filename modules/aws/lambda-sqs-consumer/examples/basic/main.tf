module "consumer" {
  source = "../.."

  function_name        = "dev-consumer"
  reserved_concurrency = 3
  tags = {
    Environment = "dev"
    Owner       = "siiick-brain"
    Project     = "kiln-infra-factory"
  }
}
