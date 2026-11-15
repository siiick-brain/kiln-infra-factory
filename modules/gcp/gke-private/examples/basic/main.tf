provider "google" {
  project = "project-example"
  region  = "us-central1"
}

module "gke" {
  source = "../.."

  project_id             = "project-example"
  name                   = "kiln-example"
  region                 = "us-central1"
  network                = "projects/host-example/global/networks/shared"
  subnetwork             = "projects/host-example/regions/us-central1/subnetworks/service"
  master_ipv4_cidr_block = "172.16.0.0/28"
  authorized_networks    = ["10.40.0.0/20"]
  labels = {
    environment = "dev"
    owner       = "siiick-brain"
    project     = "kiln-infra-factory"
  }
}
