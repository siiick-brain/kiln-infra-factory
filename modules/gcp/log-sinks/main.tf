resource "google_storage_bucket" "logs" {
  project                     = var.project_id
  name                        = "${var.name}-logs"
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false
  labels                      = var.labels
}

resource "google_bigquery_dataset" "logs" {
  project                    = var.project_id
  dataset_id                 = "${replace(var.name, "-", "_")}_logs"
  location                   = var.region
  delete_contents_on_destroy = false
  labels                     = var.labels
}

resource "google_logging_project_sink" "storage" {
  project                = var.project_id
  name                   = "${var.name}-storage"
  destination            = "storage.googleapis.com/${google_storage_bucket.logs.name}"
  filter                 = var.filter
  unique_writer_identity = true

  dynamic "exclusions" {
    for_each = var.exclusions
    content {
      name   = exclusions.value.name
      filter = exclusions.value.filter
    }
  }
}

resource "google_logging_project_sink" "bigquery" {
  project                = var.project_id
  name                   = "${var.name}-bigquery"
  destination            = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${google_bigquery_dataset.logs.dataset_id}"
  filter                 = var.filter
  unique_writer_identity = true

  dynamic "exclusions" {
    for_each = var.exclusions
    content {
      name   = exclusions.value.name
      filter = exclusions.value.filter
    }
  }
}

resource "google_storage_bucket_iam_member" "writer" {
  bucket = google_storage_bucket.logs.name
  role   = "roles/storage.objectCreator"
  member = google_logging_project_sink.storage.writer_identity
}

resource "google_bigquery_dataset_iam_member" "writer" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.logs.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.bigquery.writer_identity
}
