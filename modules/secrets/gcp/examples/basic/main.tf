provider "google" {
  project = "project-example"
  region  = "us-central1"
}

module "secret_access" {
  source = "../.."

  secret_id = "projects/project-example/secrets/application-database"
  member    = "serviceAccount:runtime@project-example.iam.gserviceaccount.com"
}
