# AWS CloudFront static site

Creates a private S3 origin with OAC, TLS 1.2 minimum, security response headers and access logging. Validate and test this module with mocked providers. Moto does not verify edge delivery or these CloudFront controls.

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
| [aws_cloudfront_distribution.site](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_control.origin](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_cloudfront_response_headers_policy.security](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/cloudfront_response_headers_policy) | resource |
| [aws_s3_bucket.origin](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.origin](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.origin](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.origin](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.origin](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/resources/s3_bucket_versioning) | resource |
| [aws_iam_policy_document.origin](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_aliases"></a> [aliases](#input\_aliases) | Optional DNS names for the distribution. | `list(string)` | `[]` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Private S3 origin bucket name. | `string` | n/a | yes |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ACM certificate ARN in us-east-1 when aliases are configured. | `string` | `null` | no |
| <a name="input_logging_bucket_domain_name"></a> [logging\_bucket\_domain\_name](#input\_logging\_bucket\_domain\_name) | S3 bucket domain for CloudFront access logs. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags. Environment, Owner and Project are required. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_distribution_domain_name"></a> [distribution\_domain\_name](#output\_distribution\_domain\_name) | CloudFront distribution domain name. |
| <a name="output_distribution_id"></a> [distribution\_id](#output\_distribution\_id) | CloudFront distribution identifier. |
| <a name="output_origin_bucket_arn"></a> [origin\_bucket\_arn](#output\_origin\_bucket\_arn) | Private S3 origin bucket ARN. |
<!-- END_TF_DOCS -->
