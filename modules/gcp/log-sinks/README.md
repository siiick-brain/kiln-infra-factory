# GCP log sinks

Creates project sinks for a private Cloud Storage bucket and BigQuery dataset. Each sink has a unique writer identity and explicit exclusion filters. IAM grants are limited to the destination.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|---|---:|
| terraform | >= 1.11.0, < 2.0.0 |
| google | = 8.9.0 |

## Inputs

| Name | Description |
|---|---|
| project_id | Project whose logs are exported. |
| name | Log export prefix. |
| region | Cloud Storage bucket region. |
| filter | Required filter for both project sinks. |
| exclusions | Explicit log exclusions applied to both sinks. |
| labels | Resource labels. |

## Outputs

| Name | Description |
|---|---|
| storage_sink_writer_identity | Unique writer identity for the storage sink. |
| bigquery_sink_writer_identity | Unique writer identity for the BigQuery sink. |
| storage_bucket_name | Log archive bucket name. |
| bigquery_dataset_id | Log archive dataset ID. |
<!-- END_TF_DOCS -->
