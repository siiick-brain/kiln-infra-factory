module "queue" {
  source = "../.."

  name = "dev-events"
  tags = {
    Environment = "dev"
    Owner       = "siiick-brain"
    Project     = "kiln-infra-factory"
  }
}
