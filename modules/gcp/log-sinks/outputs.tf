output "storage_sink_writer_identity" {
  value       = google_logging_project_sink.storage.writer_identity
  description = "Unique writer identity for the storage sink."
}

output "bigquery_sink_writer_identity" {
  value       = google_logging_project_sink.bigquery.writer_identity
  description = "Unique writer identity for the BigQuery sink."
}

output "storage_bucket_name" {
  value       = google_storage_bucket.logs.name
  description = "Log archive bucket name."
}

output "bigquery_dataset_id" {
  value       = google_bigquery_dataset.logs.dataset_id
  description = "Log archive dataset ID."
}
