mock_provider "google" {}

run "assigns_accessor_to_one_secret" {
  command = plan

  variables {
    secret_id = "projects/project-test/secrets/application-database"
    member    = "serviceAccount:runtime@project-test.iam.gserviceaccount.com"
  }

  assert {
    condition     = google_secret_manager_secret_iam_member.accessor.secret_id == var.secret_id
    error_message = "The IAM binding must be scoped to the supplied secret."
  }

  assert {
    condition     = google_secret_manager_secret_iam_member.accessor.role == "roles/secretmanager.secretAccessor"
    error_message = "The IAM binding must grant only secret accessor."
  }
}
