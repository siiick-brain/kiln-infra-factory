module "site" {
  source = "../.."

  bucket_name                = "kiln-static-example"
  logging_bucket_domain_name = "kiln-access-logs.s3.amazonaws.com"
  tags = {
    Environment = "dev"
    Owner       = "siiick-brain"
    Project     = "kiln-infra-factory"
  }
}
