# AWS CloudFront static site

Creates a private S3 origin with OAC, TLS 1.2 minimum, security response headers and access logging. Validate and test this module with mocked providers. Moto does not verify edge delivery or these CloudFront controls.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|---|---:|
| terraform | >= 1.11.0, < 2.0.0 |
| aws | = 6.71.0 |

## Inputs

| Name | Description |
|---|---|
| bucket_name | Private S3 origin bucket name. |
| logging_bucket_domain_name | S3 bucket domain for CloudFront access logs. |
| aliases | Optional DNS names for the distribution. |
| certificate_arn | ACM certificate ARN in us-east-1 when aliases are configured. |
| tags | Resource tags. Environment, Owner and Project are required. |

## Outputs

| Name | Description |
|---|---|
| distribution_id | CloudFront distribution identifier. |
| distribution_domain_name | CloudFront distribution domain name. |
| origin_bucket_arn | Private S3 origin bucket ARN. |
<!-- END_TF_DOCS -->
