# ADR 0001: Use Moto for local AWS tests

## Status

Accepted

## Context

AWS module plans and integration tests must run without an AWS account, cloud credentials or charges. The emulator needs S3, SQS, Lambda, IAM and STS support. LocalStack's current installation guide requires an Auth Token and a browser login for a first start. That does not meet the accountless project constraint.

Moto is Apache-2.0 licensed and its documented service list includes S3, SQS, Lambda, IAM and STS. The documented API lists include unsupported operations. Emulator behavior is not equivalent to AWS behavior.

## Decision

Use Moto server 5.2.5 in a locally built container. Pin the Python base image by digest and bind its public endpoint to localhost. The Compose service mounts the Docker socket only because Moto runs Lambda code in Docker containers. Do not mount cloud credentials.

Terraform's emulator provider configuration uses fake local credentials. No module is applied to a real AWS account.

## Coverage limits

- Moto covers the required AWS APIs at the level of its documented implementations. Unsupported or incomplete operations remain outside the emulator claim.
- CloudFront features in `cloudfront-static`, including OAC, TLS, response headers and edge delivery, are validated and tested with mocked providers only.
- Moto 5.2.5 did not return the `RedriveAllowPolicy` attribute from SQS `GetQueueAttributes` during the local apply attempt. The dev Terragrunt units disable only the explicit DLQ source restriction because Terraform waits for that missing attribute. The modules keep this policy enabled by default. Module tests cover the default. Emulator apply does not verify this restriction.
- Azure and GCP modules are validated and tested with mocked providers only.
- Real IAM evaluation, AWS networking behavior, Lambda execution fidelity and service availability are not verified by Moto tests.
- No emulator result proves that a real cloud deployment is safe or ready.

## Alternatives

- LocalStack was not selected because its current setup requires an Auth Token and account login.
- Direct AWS testing was rejected because it would touch a real cloud account and could incur charges.

## Sources checked on 2026-10-30

- [Moto supported services](https://docs.getmoto.org/en/latest/docs/services/index.html)
- [Moto S3 behavior](https://docs.getmoto.org/en/latest/docs/services/s3.html)
- [Moto Lambda behavior](https://docs.getmoto.org/en/latest/docs/services/lambda.html)
- [Moto IAM behavior](https://docs.getmoto.org/en/latest/docs/services/iam.html)
- [Moto SQS behavior](https://docs.getmoto.org/en/latest/docs/services/sqs.html)
- [Moto STS behavior](https://docs.getmoto.org/en/latest/docs/services/sts.html)
- [LocalStack installation and authentication](https://docs.localstack.cloud/aws/getting-started/installation/)
