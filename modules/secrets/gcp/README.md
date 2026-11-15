# GCP Secret Manager access

Grants the Secret Manager Secret Accessor role to one specific principal on one secret. The module does not create or read secret values.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|---|---:|
| terraform | >= 1.11.0, < 2.0.0 |
| google | = 8.9.0 |

## Inputs

| Name | Description |
|---|---|
| secret_id | Full resource name of one existing Secret Manager secret. |
| member | Specific IAM principal receiving secret accessor access. |

## Outputs

| Name | Description |
|---|---|
| iam_member_id | ID of the secret-scoped accessor binding. |
| secret_id | Secret resource receiving the binding. |
<!-- END_TF_DOCS -->
