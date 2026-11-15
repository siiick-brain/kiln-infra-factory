output "pool_name" {
  value       = google_iam_workload_identity_pool.github.name
  description = "Workload identity pool resource name."
}

output "provider_name" {
  value       = google_iam_workload_identity_pool_provider.github.name
  description = "GitHub OIDC provider resource name."
}

output "service_account_email" {
  value       = google_service_account.github.email
  description = "Federated service account email."
}
