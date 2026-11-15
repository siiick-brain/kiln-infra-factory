# GCP log sinks

Creates project sinks for a private Cloud Storage bucket and BigQuery dataset. Each sink has a unique writer identity and explicit exclusion filters. IAM grants are limited to the destination.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | = 8.9.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | 8.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_bigquery_dataset.logs](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/bigquery_dataset) | resource |
| [google_bigquery_dataset_iam_member.writer](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/bigquery_dataset_iam_member) | resource |
| [google_logging_project_sink.bigquery](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/logging_project_sink) | resource |
| [google_logging_project_sink.storage](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/logging_project_sink) | resource |
| [google_storage_bucket.logs](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.writer](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/storage_bucket_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_exclusions"></a> [exclusions](#input\_exclusions) | Explicit log exclusions applied to both sinks. | <pre>list(object({<br/>    name   = string<br/>    filter = string<br/>  }))</pre> | `[]` | no |
| <a name="input_filter"></a> [filter](#input\_filter) | Required filter for both project sinks. | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Resource labels. environment, owner and project are required. | `map(string)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Log export prefix. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project whose logs are exported. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Cloud Storage bucket region. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_bigquery_dataset_id"></a> [bigquery\_dataset\_id](#output\_bigquery\_dataset\_id) | Log archive dataset ID. |
| <a name="output_bigquery_sink_writer_identity"></a> [bigquery\_sink\_writer\_identity](#output\_bigquery\_sink\_writer\_identity) | Unique writer identity for the BigQuery sink. |
| <a name="output_storage_bucket_name"></a> [storage\_bucket\_name](#output\_storage\_bucket\_name) | Log archive bucket name. |
| <a name="output_storage_sink_writer_identity"></a> [storage\_sink\_writer\_identity](#output\_storage\_sink\_writer\_identity) | Unique writer identity for the storage sink. |
<!-- END_TF_DOCS -->
