provider "google" {
  project = "host-example"
  region  = "us-central1"
}

module "shared_vpc" {
  source = "../.."

  host_project_id        = "host-example"
  service_project_id     = "service-example"
  service_project_number = "123456789012"
  network_name           = "kiln-example"
  region                 = "us-central1"
  subnet_cidr            = "10.40.0.0/20"
  labels = {
    environment = "dev"
    owner       = "siiick-brain"
    project     = "kiln-infra-factory"
  }
}
