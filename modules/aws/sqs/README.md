# AWS SQS queue

Creates an encrypted queue, an encrypted dead-letter queue and a queue policy that rejects insecure transport.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|---|---:|
| terraform | >= 1.11.0, < 2.0.0 |
| aws | = 6.71.0 |

## Inputs

| Name | Description |
|---|---|
| name | Queue name. |
| max_receive_count | Receive count before a message moves to the dead-letter queue. |
| enable_redrive_allow_policy | Whether to restrict the DLQ source queue. Disable only for emulators that cannot read this attribute. |
| tags | Resource tags. Environment, Owner and Project are required. |

## Outputs

| Name | Description |
|---|---|
| queue_arn | Queue ARN. |
| queue_url | Queue URL. |
| dead_letter_queue_arn | Dead-letter queue ARN. |
<!-- END_TF_DOCS -->
