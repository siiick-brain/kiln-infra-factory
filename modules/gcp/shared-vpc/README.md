# GCP Shared VPC

Attaches a service project to a host project, creates a subnet and Cloud NAT, grants subnet use to the service project agent and denies ingress and egress by default for tagged workloads.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | = 8.9.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | 8.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_compute_firewall.deny_egress](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.deny_ingress](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/compute_firewall) | resource |
| [google_compute_network.shared](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/compute_network) | resource |
| [google_compute_router.nat](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/compute_router) | resource |
| [google_compute_router_nat.nat](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/compute_router_nat) | resource |
| [google_compute_shared_vpc_host_project.host](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/compute_shared_vpc_host_project) | resource |
| [google_compute_shared_vpc_service_project.service](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/compute_shared_vpc_service_project) | resource |
| [google_compute_subnetwork.service](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork_iam_member.network_user](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/compute_subnetwork_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_host_project_id"></a> [host\_project\_id](#input\_host\_project\_id) | Host project ID. | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Resource labels. environment, owner and project are required. | `map(string)` | n/a | yes |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Shared VPC network name. | `string` | n/a | yes |
| <a name="input_network_tags"></a> [network\_tags](#input\_network\_tags) | Instance tags targeted by default-deny firewall rules. | `list(string)` | <pre>[<br/>  "kiln-workload"<br/>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | Region for the subnet and Cloud NAT. | `string` | n/a | yes |
| <a name="input_service_project_id"></a> [service\_project\_id](#input\_service\_project\_id) | Attached service project ID. | `string` | n/a | yes |
| <a name="input_service_project_number"></a> [service\_project\_number](#input\_service\_project\_number) | Numeric service project ID for the Shared VPC service agent. | `string` | n/a | yes |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | IPv4 CIDR range for the service subnet. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | Shared VPC network ID. |
| <a name="output_router_nat_name"></a> [router\_nat\_name](#output\_router\_nat\_name) | Cloud NAT name. |
| <a name="output_subnetwork_id"></a> [subnetwork\_id](#output\_subnetwork\_id) | Service project subnet ID. |
<!-- END_TF_DOCS -->
