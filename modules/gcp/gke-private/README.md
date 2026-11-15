# GCP private GKE

Creates a private GKE cluster with private nodes and endpoint, Workload Identity, network policy and shielded nodes. The default node tag matches the Shared VPC deny rules. The node identity receives only logging and monitoring writer roles.

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
| [google_container_cluster.private](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/container_cluster) | resource |
| [google_container_node_pool.private](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/container_node_pool) | resource |
| [google_project_iam_member.node_logging](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.node_monitoring](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/project_iam_member) | resource |
| [google_service_account.nodes](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/service_account) | resource |
| [google_service_account_iam_member.gke_workload_identity](https://registry.terraform.io/providers/hashicorp/google/8.9.0/docs/resources/service_account_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_authorized_networks"></a> [authorized\_networks](#input\_authorized\_networks) | CIDR ranges allowed to reach the private control plane. | `list(string)` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Resource labels. environment, owner and project are required. | `map(string)` | n/a | yes |
| <a name="input_master_ipv4_cidr_block"></a> [master\_ipv4\_cidr\_block](#input\_master\_ipv4\_cidr\_block) | Private control plane CIDR. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | GKE cluster name. | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Shared VPC network self-link. | `string` | n/a | yes |
| <a name="input_network_tags"></a> [network\_tags](#input\_network\_tags) | Network tags for GKE nodes. The default matches the Shared VPC deny rules. | `list(string)` | <pre>[<br/>  "kiln-workload"<br/>]</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GKE region. | `string` | n/a | yes |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | Shared VPC subnet self-link. | `string` | n/a | yes |
| <a name="input_workload_identity_bindings"></a> [workload\_identity\_bindings](#input\_workload\_identity\_bindings) | Google service accounts that exact Kubernetes service accounts may impersonate. | <pre>list(object({<br/>    service_account_email      = string<br/>    namespace                  = string<br/>    kubernetes_service_account = string<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Private GKE control plane endpoint. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Private GKE cluster name. |
| <a name="output_node_service_account"></a> [node\_service\_account](#output\_node\_service\_account) | Least-privilege node service account email. |
<!-- END_TF_DOCS -->
