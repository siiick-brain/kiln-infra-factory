# AWS state bootstrap

Creates a private S3 bucket with versioning and server-side encryption. The default transport policy blocks insecure requests. Configure the Terraform S3 backend with `use_lockfile = true` to use native state locking. Set `enforce_secure_transport = false` only when testing against the local HTTP emulator. Do not store credentials in state.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|---|---:|
| terraform | >= 1.11.0, < 2.0.0 |
| aws | = 6.71.0 |

## Inputs

| Name | Description |
|---|---|
| bucket_name | Globally unique S3 bucket name for Terraform state. |
| enforce_secure_transport | Deny unencrypted transport. Disable only for the local HTTP emulator. |
| tags | Resource tags. Environment, Owner and Project are required. |

## Outputs

| Name | Description |
|---|---|
| bucket_name | Terraform state bucket name. |
| bucket_arn | Terraform state bucket ARN. |
<!-- END_TF_DOCS -->
