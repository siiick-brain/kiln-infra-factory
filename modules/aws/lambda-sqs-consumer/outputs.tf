output "function_arn" {
  value       = aws_lambda_function.consumer.arn
  description = "Consumer function ARN."
}

output "queue_arn" {
  value       = aws_sqs_queue.main.arn
  description = "Source queue ARN."
}

output "dead_letter_queue_arn" {
  value       = aws_sqs_queue.dead_letter.arn
  description = "Dead-letter queue ARN."
}

output "execution_role_arn" {
  value       = aws_iam_role.lambda.arn
  description = "Least-privilege execution role ARN."
}
