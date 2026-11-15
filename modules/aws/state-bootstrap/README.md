# AWS state bootstrap

Creates a private S3 bucket with versioning and server-side encryption. The default transport policy blocks insecure requests. Configure the Terraform S3 backend with `use_lockfile = true` to use native state locking. Set `enforce_secure_transport = false` only when testing against the local HTTP emulator. Do not store credentials in state.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | = 6.71.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.71.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_s3_bucket.state](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.state](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.state](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.state](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.state](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/s3_bucket_versioning) | resource |
| [aws_iam_policy_document.deny_insecure_transport](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Globally unique S3 bucket name for Terraform state. | `string` | n/a | yes |
| <a name="input_enforce_secure_transport"></a> [enforce\_secure\_transport](#input\_enforce\_secure\_transport) | Deny unencrypted transport. Disable only for the local HTTP emulator. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags. Environment, Owner and Project are required. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | Terraform state bucket ARN. |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Terraform state bucket name. |
<!-- END_TF_DOCS -->
