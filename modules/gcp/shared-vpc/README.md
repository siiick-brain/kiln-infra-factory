# GCP Shared VPC

Attaches a service project to a host project, creates a subnet and Cloud NAT, grants subnet use to the service project agent and denies ingress and egress by default for tagged workloads.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|---|---:|
| terraform | >= 1.11.0, < 2.0.0 |
| google | = 8.9.0 |

## Inputs

| Name | Description |
|---|---|
| host_project_id | Host project ID. |
| service_project_id | Attached service project ID. |
| service_project_number | Numeric service project ID. |
| network_name | Shared VPC network name. |
| region | Region for the subnet and Cloud NAT. |
| subnet_cidr | IPv4 CIDR range. |
| network_tags | Instance tags targeted by deny rules. |
| labels | Resource labels. |

## Outputs

| Name | Description |
|---|---|
| network_id | Shared VPC network ID. |
| subnetwork_id | Service project subnet ID. |
| router_nat_name | Cloud NAT name. |
<!-- END_TF_DOCS -->
