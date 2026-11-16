resource "google_service_account" "nodes" {
  project      = var.project_id
  account_id   = "${var.name}-nodes"
  display_name = "Least-privilege GKE node identity for ${var.name}"
}

resource "google_project_iam_member" "node_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.nodes.email}"
}

resource "google_project_iam_member" "node_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.nodes.email}"
}

resource "google_service_account_iam_member" "gke_workload_identity" {
  for_each = {
    for binding in var.workload_identity_bindings :
    "${binding.namespace}/${binding.kubernetes_service_account}" => binding
  }

  service_account_id = "projects/${var.project_id}/serviceAccounts/${each.value.service_account_email}"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${each.value.namespace}/${each.value.kubernetes_service_account}]"
}

resource "google_container_cluster" "private" {
  project                     = var.project_id
  name                        = var.name
  location                    = var.region
  network                     = var.network
  subnetwork                  = var.subnetwork
  remove_default_node_pool    = true
  initial_node_count          = 1
  enable_shielded_nodes       = true
  enable_intranode_visibility = true
  deletion_protection         = true
  resource_labels             = var.labels

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.authorized_networks
      content {
        cidr_block   = cidr_blocks.value
        display_name = "approved"
      }
    }
  }

  ip_allocation_policy {}

  release_channel {
    channel = "REGULAR"
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "private" {
  project    = var.project_id
  name       = "${var.name}-nodes"
  location   = var.region
  cluster    = google_container_cluster.private.name
  node_count = 1

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    service_account = google_service_account.nodes.email
    machine_type    = "e2-medium"
    tags            = var.network_tags
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = var.labels
  }
}
