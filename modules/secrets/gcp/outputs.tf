output "iam_member_id" {
  value       = google_secret_manager_secret_iam_member.accessor.id
  description = "ID of the secret-scoped accessor binding."
}

output "secret_id" {
  value       = google_secret_manager_secret_iam_member.accessor.secret_id
  description = "Secret resource receiving the binding."
}
