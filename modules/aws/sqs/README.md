# AWS SQS queue

Creates an encrypted queue, an encrypted dead-letter queue and a queue policy that rejects insecure transport.

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
| [aws_sqs_queue.dead_letter](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.main](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.main](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/sqs_queue_policy) | resource |
| [aws_sqs_queue_redrive_allow_policy.dead_letter](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/sqs_queue_redrive_allow_policy) | resource |
| [aws_iam_policy_document.deny_insecure_transport](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_enable_redrive_allow_policy"></a> [enable\_redrive\_allow\_policy](#input\_enable\_redrive\_allow\_policy) | Whether to restrict the DLQ source queue. Disable only for emulators that cannot read this attribute. | `bool` | `true` | no |
| <a name="input_max_receive_count"></a> [max\_receive\_count](#input\_max\_receive\_count) | Receive count before a message moves to the dead-letter queue. | `number` | `5` | no |
| <a name="input_name"></a> [name](#input\_name) | Queue name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags. Environment, Owner and Project are required. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dead_letter_queue_arn"></a> [dead\_letter\_queue\_arn](#output\_dead\_letter\_queue\_arn) | Dead-letter queue ARN. |
| <a name="output_queue_arn"></a> [queue\_arn](#output\_queue\_arn) | Queue ARN. |
| <a name="output_queue_url"></a> [queue\_url](#output\_queue\_url) | Queue URL. |
<!-- END_TF_DOCS -->
