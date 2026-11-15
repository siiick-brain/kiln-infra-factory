mock_provider "aws" {}

run "requires_tls_and_private_origin" {
  command = plan

  variables {
    bucket_name                = "kiln-static-test"
    logging_bucket_domain_name = "kiln-logs.s3.amazonaws.com"
    tags = {
      Environment = "test"
      Owner       = "siiick-brain"
      Project     = "kiln-infra-factory"
    }
  }

  assert {
    condition     = aws_cloudfront_distribution.site.viewer_certificate[0].minimum_protocol_version == "TLSv1.2_2021"
    error_message = "CloudFront must require TLS 1.2 or later."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.origin.block_public_policy
    error_message = "The S3 origin must block public policies."
  }
}
