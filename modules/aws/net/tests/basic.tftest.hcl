mock_provider "aws" {}

run "creates_vpc_with_no_public_subnet" {
  command = apply

  variables {
    name             = "test-net"
    cidr_block       = "10.40.0.0/16"
    flow_logs_s3_arn = "arn:aws:s3:::example-flow-logs"
    tags = {
      Environment = "test"
      Owner       = "siiick-brain"
      Project     = "kiln-infra-factory"
    }
  }

  assert {
    condition     = aws_vpc.this.cidr_block == "10.40.0.0/16"
    error_message = "The VPC must use the requested CIDR."
  }

  assert {
    condition     = length(aws_security_group.this.egress) == 0
    error_message = "Security group egress must deny traffic by default."
  }
}

run "allows_only_explicit_egress_rules" {
  command = apply

  variables {
    name             = "test-net"
    cidr_block       = "10.40.0.0/16"
    flow_logs_s3_arn = "arn:aws:s3:::example-flow-logs"
    egress_rules = [{
      description = "Approved HTTPS egress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
    }]
    tags = {
      Environment = "test"
      Owner       = "siiick-brain"
      Project     = "kiln-infra-factory"
    }
  }

  assert {
    condition     = length(aws_security_group.this.egress) == 1 && one(aws_security_group.this.egress).from_port == 443
    error_message = "Only explicitly configured egress rules may be allowed."
  }
}
