# GCP private GKE

Creates a private GKE cluster with private nodes and endpoint, Workload Identity, network policy and shielded nodes. The default node tag matches the Shared VPC deny rules. The node identity receives only logging and monitoring writer roles.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|---|---:|
| terraform | >= 1.11.0, < 2.0.0 |
| google | = 8.9.0 |

## Inputs

| Name | Description |
|---|---|
| project_id | GCP project ID. |
| name | GKE cluster name. |
| region | GKE region. |
| network | Shared VPC network self-link. |
| subnetwork | Shared VPC subnet self-link. |
| master_ipv4_cidr_block | Private control plane CIDR. |
| authorized_networks | CIDR ranges allowed to reach the private control plane. |
| network_tags | Network tags for GKE nodes. |
| workload_identity_bindings | Google service accounts that exact Kubernetes service accounts may impersonate. |
| labels | Resource labels. |

## Outputs

| Name | Description |
|---|---|
| cluster_name | Private GKE cluster name. |
| cluster_endpoint | Private GKE control plane endpoint. |
| node_service_account | Least-privilege node service account email. |
<!-- END_TF_DOCS -->
