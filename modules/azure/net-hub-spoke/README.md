# Azure hub and spoke network

Creates hub and spoke VNets, bidirectional peering, workload subnets, NAT and deny-by-default NSGs. The module defines no allow exceptions.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|---|---:|
| terraform | >= 1.11.0, < 2.0.0 |
| azurerm | = 5.12.0 |

## Inputs

| Name | Description |
|---|---|
| name | Network name prefix. |
| resource_group_name | Existing resource group name. |
| location | Azure region. |
| hub_address_space | Hub virtual network CIDR. |
| spoke_address_space | Spoke virtual network CIDR. |
| network_tags | Network tags for workload firewall rules. |
| tags | Resource tags. Environment, Owner and Project are required. |

## Outputs

| Name | Description |
|---|---|
| hub_vnet_id | Hub virtual network ID. |
| spoke_vnet_id | Spoke virtual network ID. |
| spoke_subnet_id | Spoke workload subnet ID. |
| spoke_nat_gateway_id | Spoke NAT gateway ID. |
<!-- END_TF_DOCS -->
