output "queue_arn" {
  value       = aws_sqs_queue.main.arn
  description = "Queue ARN."
}

output "queue_url" {
  value       = aws_sqs_queue.main.url
  description = "Queue URL."
}

output "dead_letter_queue_arn" {
  value       = aws_sqs_queue.dead_letter.arn
  description = "Dead-letter queue ARN."
}
