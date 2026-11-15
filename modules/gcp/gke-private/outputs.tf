output "cluster_name" {
  value       = google_container_cluster.private.name
  description = "Private GKE cluster name."
}

output "cluster_endpoint" {
  value       = google_container_cluster.private.endpoint
  description = "Private GKE control plane endpoint."
}

output "node_service_account" {
  value       = google_service_account.nodes.email
  description = "Least-privilege node service account email."
}
