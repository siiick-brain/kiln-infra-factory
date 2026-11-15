output "network_id" {
  value       = google_compute_network.shared.id
  description = "Shared VPC network ID."
}

output "subnetwork_id" {
  value       = google_compute_subnetwork.service.id
  description = "Service project subnet ID."
}

output "router_nat_name" {
  value       = google_compute_router_nat.nat.name
  description = "Cloud NAT name."
}
