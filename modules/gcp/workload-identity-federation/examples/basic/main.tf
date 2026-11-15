provider "google" {
  project = "project-example"
  region  = "us-central1"
}

module "github_identity" {
  source = "../.."

  project_id         = "project-example"
  pool_id            = "github-pool"
  provider_id        = "github-provider"
  service_account_id = "github-deploy"
  github_repository  = "example/repository"
  github_ref         = "refs/heads/main"
}
