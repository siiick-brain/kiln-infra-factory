resource "google_container_cluster" "bad" {
  project     = "test-project"
  name        = "test-cluster"
  location    = "us-central1"
  network     = "test-network"
  subnetwork  = "test-subnet"

  private_cluster_config {
    enable_private_nodes    = false
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  workload_identity_config {
    workload_pool = ""
  }

  resource_labels = {
    environment = "test"
    owner       = "siiick-brain"
    project     = "kiln-infra-factory"
  }
}
