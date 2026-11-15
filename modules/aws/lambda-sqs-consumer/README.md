# AWS Lambda SQS consumer

Builds a ZIP from `lambda/`. It creates an encrypted source queue and dead-letter queue and grants the function only queue-consumption and log-write permissions. Reserved concurrency is bounded by default.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0, < 2.0.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | = 2.8.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | = 6.71.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.8.1 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.71.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_log_group.lambda](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.lambda](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.lambda](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/iam_role_policy) | resource |
| [aws_lambda_event_source_mapping.queue](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_function.consumer](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/lambda_function) | resource |
| [aws_sqs_queue.dead_letter](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.main](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_redrive_allow_policy.dead_letter](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/sqs_queue_redrive_allow_policy) | resource |
| [archive_file.function](https://registry.terraform.io/providers/hashicorp/archive/2.8.1/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_enable_redrive_allow_policy"></a> [enable\_redrive\_allow\_policy](#input\_enable\_redrive\_allow\_policy) | Whether to restrict the DLQ source queue. Disable only for emulators that cannot read this attribute. | `bool` | `true` | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Function and queue name prefix. | `string` | n/a | yes |
| <a name="input_reserved_concurrency"></a> [reserved\_concurrency](#input\_reserved\_concurrency) | Maximum concurrent function executions. | `number` | `5` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags. Environment, Owner and Project are required. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dead_letter_queue_arn"></a> [dead\_letter\_queue\_arn](#output\_dead\_letter\_queue\_arn) | Dead-letter queue ARN. |
| <a name="output_execution_role_arn"></a> [execution\_role\_arn](#output\_execution\_role\_arn) | Least-privilege execution role ARN. |
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | Consumer function ARN. |
| <a name="output_queue_arn"></a> [queue\_arn](#output\_queue\_arn) | Source queue ARN. |
<!-- END_TF_DOCS -->
