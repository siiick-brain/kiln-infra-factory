output "policy_id" {
  value       = aws_iam_role_policy.secret_access.id
  description = "ID of the inline secret access policy."
}

output "policy_json" {
  value       = aws_iam_role_policy.secret_access.policy
  description = "Read-only policy scoped to the supplied secret ARN."
}
