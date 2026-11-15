# AWS network

Creates a VPC, public and private subnets, a NAT gateway, routes, a security group and VPC flow logs. Ingress and egress are closed unless explicit rules are supplied. The example uses documentation-only values.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|---|---:|
| terraform | >= 1.11.0, < 2.0.0 |
| aws | = 6.71.0 |

## Inputs

| Name | Description |
|---|---|
| name | Name prefix for network resources. |
| cidr_block | IPv4 CIDR range for the VPC. |
| public_subnets | Public subnet CIDRs and availability zones. |
| private_subnets | Private subnet CIDRs and availability zones. |
| flow_logs_s3_arn | S3 destination ARN for VPC flow logs. |
| ingress_rules | Explicit security group ingress rules. |
| egress_rules | Explicit security group egress allow rules. Empty denies all egress. |
| tags | Resource tags. Environment, Owner and Project are required. |

## Outputs

| Name | Description |
|---|---|
| vpc_id | VPC identifier. |
| public_subnet_ids | Public subnet identifiers. |
| private_subnet_ids | Private subnet identifiers. |
| security_group_id | Default security group identifier. |
<!-- END_TF_DOCS -->
