mock_provider "google" {}

run "creates_unique_sinks_and_private_storage" {
  command = plan

  variables {
    project_id = "project-test"
    name       = "kiln-test"
    region     = "us-central1"
    filter     = "resource.type = gce_instance"
    labels = {
      environment = "test"
      owner       = "siiick-brain"
      project     = "kiln-infra-factory"
    }
  }

  assert {
    condition     = google_logging_project_sink.storage.unique_writer_identity && google_logging_project_sink.bigquery.unique_writer_identity
    error_message = "Each sink must use a unique writer identity."
  }

  assert {
    condition     = google_storage_bucket.logs.public_access_prevention == "enforced"
    error_message = "Log storage must block public access."
  }
}
