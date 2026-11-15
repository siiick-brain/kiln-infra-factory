data "archive_file" "function" {
  type        = "zip"
  source_file = "${path.module}/lambda/handler.py"
  output_path = "${path.root}/.terraform/${var.function_name}.zip"
}

resource "aws_sqs_queue" "dead_letter" {
  name                      = "${var.function_name}-dlq"
  sqs_managed_sse_enabled   = true
  message_retention_seconds = 1209600
  tags                      = merge(var.tags, { Name = "${var.function_name}-dlq" })
}

resource "aws_sqs_queue" "main" {
  name                       = "${var.function_name}-queue"
  sqs_managed_sse_enabled    = true
  visibility_timeout_seconds = 180
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter.arn
    maxReceiveCount     = 5
  })
  tags = merge(var.tags, { Name = "${var.function_name}-queue" })
}

resource "aws_sqs_queue_redrive_allow_policy" "dead_letter" {
  count     = var.enable_redrive_allow_policy ? 1 : 0
  queue_url = aws_sqs_queue.dead_letter.id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.main.arn]
  })
}

resource "aws_iam_role" "lambda" {
  name = "${var.function_name}-execution"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
  tags = merge(var.tags, { Name = "${var.function_name}-execution" })
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 365
  tags              = var.tags
}

resource "aws_iam_role_policy" "lambda" {
  name = "${var.function_name}-consumer"
  role = aws_iam_role.lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.main.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.lambda.arn}:*"
      }
    ]
  })
}

resource "aws_lambda_function" "consumer" {
  function_name                  = var.function_name
  role                           = aws_iam_role.lambda.arn
  runtime                        = "python3.12"
  handler                        = "handler.lambda_handler"
  filename                       = data.archive_file.function.output_path
  source_code_hash               = data.archive_file.function.output_base64sha256
  timeout                        = 30
  memory_size                    = 128
  reserved_concurrent_executions = var.reserved_concurrency
  tags                           = var.tags
}

resource "aws_lambda_event_source_mapping" "queue" {
  event_source_arn        = aws_sqs_queue.main.arn
  function_name           = aws_lambda_function.consumer.arn
  batch_size              = 10
  function_response_types = ["ReportBatchItemFailures"]
  enabled                 = true
}
