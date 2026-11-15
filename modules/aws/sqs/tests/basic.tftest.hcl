mock_provider "aws" {}

run "creates_encrypted_queue_and_dlq" {
  command = plan

  variables {
    name = "test-events"
    tags = {
      Environment = "test"
      Owner       = "siiick-brain"
      Project     = "kiln-infra-factory"
    }
  }

  assert {
    condition     = aws_sqs_queue.main.sqs_managed_sse_enabled
    error_message = "The main queue must be encrypted."
  }

  assert {
    condition     = aws_sqs_queue.dead_letter.sqs_managed_sse_enabled
    error_message = "The dead-letter queue must be encrypted."
  }
}

run "enables_dlq_source_restriction_by_default" {
  command = plan

  variables {
    name = "test-events"
    tags = {
      Environment = "test"
      Owner       = "siiick-brain"
      Project     = "kiln-infra-factory"
    }
  }

  assert {
    condition     = length(aws_sqs_queue_redrive_allow_policy.dead_letter) == 1
    error_message = "The DLQ source restriction must be enabled by default."
  }
}

run "allows_emulator_to_skip_unsupported_dlq_read" {
  command = plan

  variables {
    name                        = "test-events"
    enable_redrive_allow_policy = false
    tags = {
      Environment = "test"
      Owner       = "siiick-brain"
      Project     = "kiln-infra-factory"
    }
  }

  assert {
    condition     = length(aws_sqs_queue_redrive_allow_policy.dead_letter) == 0
    error_message = "The emulator-only override must omit the unsupported DLQ policy resource."
  }
}
