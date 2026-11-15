mock_provider "aws" {}
mock_provider "archive" {}

run "limits_function_concurrency" {
  command = plan

  variables {
    function_name = "test-consumer"
    tags = {
      Environment = "test"
      Owner       = "siiick-brain"
      Project     = "kiln-infra-factory"
    }
  }

  assert {
    condition     = aws_lambda_function.consumer.reserved_concurrent_executions == 5
    error_message = "The function must have bounded concurrency."
  }

  assert {
    condition     = aws_sqs_queue.dead_letter.sqs_managed_sse_enabled
    error_message = "The dead-letter queue must be encrypted."
  }
}

run "enables_dlq_source_restriction_by_default" {
  command = plan

  variables {
    function_name = "test-consumer"
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
    function_name               = "test-consumer"
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
