provider "google" {
  project = "project-example"
  region  = "us-central1"
}

module "log_sinks" {
  source = "../.."

  project_id = "project-example"
  name       = "kiln-example"
  region     = "us-central1"
  filter     = "resource.type = gce_instance"
  exclusions = [{
    name   = "debug"
    filter = "severity < WARNING"
  }]
  labels = {
    environment = "dev"
    owner       = "siiick-brain"
    project     = "kiln-infra-factory"
  }
}
