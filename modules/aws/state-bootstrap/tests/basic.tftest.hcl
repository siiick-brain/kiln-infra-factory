mock_provider "aws" {}

run "enables_versioned_encrypted_state" {
  command = plan

  variables {
    bucket_name = "kiln-state-test"
    tags = {
      Environment = "test"
      Owner       = "siiick-brain"
      Project     = "kiln-infra-factory"
    }
  }

  assert {
    condition     = aws_s3_bucket_versioning.state.versioning_configuration[0].status == "Enabled"
    error_message = "State object versions must be retained."
  }

  assert {
    condition     = one([for rule in aws_s3_bucket_server_side_encryption_configuration.state.rule : one(rule.apply_server_side_encryption_by_default).sse_algorithm]) == "AES256"
    error_message = "State must use server-side encryption."
  }

  assert {
    condition     = length(aws_s3_bucket_policy.state) == 1
    error_message = "The secure transport policy must be enabled by default."
  }
}

run "allows_local_http_emulator_without_transport_policy" {
  command = plan

  variables {
    bucket_name              = "kiln-state-local"
    enforce_secure_transport = false
    tags = {
      Environment = "test"
      Owner       = "siiick-brain"
      Project     = "kiln-infra-factory"
    }
  }

  assert {
    condition     = length(aws_s3_bucket_policy.state) == 0
    error_message = "The local HTTP emulator cannot enforce a TLS-only bucket policy."
  }
}
