mock_provider "google" {}

run "restricts_oidc_to_exact_repository_and_ref" {
  command = plan

  variables {
    project_id         = "project-test"
    pool_id            = "github-pool"
    provider_id        = "github-provider"
    service_account_id = "github-deploy"
    github_repository  = "example/repository"
    github_ref         = "refs/heads/main"
  }

  assert {
    condition     = strcontains(google_iam_workload_identity_pool_provider.github.attribute_condition, "refs/heads/main")
    error_message = "OIDC trust must require the exact Git ref."
  }

  assert {
    condition     = strcontains(google_iam_workload_identity_pool_provider.github.attribute_condition, "example/repository")
    error_message = "OIDC trust must require the exact GitHub repository."
  }

  assert {
    condition     = google_service_account_iam_member.federated.role == "roles/iam.workloadIdentityUser"
    error_message = "Federation must use the workload identity user role."
  }
}
