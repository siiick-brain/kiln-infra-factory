module "network" {
  source = "../.."

  name       = "dev-network"
  cidr_block = "10.20.0.0/16"
  public_subnets = [{
    cidr_block        = "10.20.1.0/24"
    availability_zone = "us-east-1a"
  }]
  private_subnets = [{
    cidr_block        = "10.20.11.0/24"
    availability_zone = "us-east-1a"
  }]
  flow_logs_s3_arn = "arn:aws:s3:::example-flow-logs"
  tags = {
    Environment = "dev"
    Owner       = "siiick-brain"
    Project     = "kiln-infra-factory"
  }
}
