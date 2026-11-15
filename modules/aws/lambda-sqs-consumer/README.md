# AWS Lambda SQS consumer

Builds a ZIP from `lambda/`. It creates an encrypted source queue and dead-letter queue and grants the function only queue-consumption and log-write permissions. Reserved concurrency is bounded by default.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|---|---:|
| terraform | >= 1.11.0, < 2.0.0 |
| aws | = 6.71.0 |
| archive | = 2.8.1 |

## Inputs

| Name | Description |
|---|---|
| function_name | Function and queue name prefix. |
| reserved_concurrency | Maximum concurrent function executions. |
| enable_redrive_allow_policy | Whether to restrict the DLQ source queue. Disable only for emulators that cannot read this attribute. |
| tags | Resource tags. Environment, Owner and Project are required. |

## Outputs

| Name | Description |
|---|---|
| function_arn | Consumer function ARN. |
| queue_arn | Source queue ARN. |
| dead_letter_queue_arn | Dead-letter queue ARN. |
| execution_role_arn | Least-privilege execution role ARN. |
<!-- END_TF_DOCS -->
