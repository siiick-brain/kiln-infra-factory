output "role_arn" {
  value       = aws_iam_role.github.arn
  description = "GitHub Actions role ARN."
}

output "provider_arn" {
  value       = aws_iam_openid_connect_provider.github.arn
  description = "GitHub OIDC provider ARN."
}
