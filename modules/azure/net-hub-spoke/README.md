# Azure hub and spoke network

Creates hub and spoke VNets, bidirectional peering, workload subnets, NAT and deny-by-default NSGs. The module defines no allow exceptions.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | = 5.12.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 5.12.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_nat_gateway.spoke](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0/docs/resources/nat_gateway) | resource |
| [azurerm_nat_gateway_public_ip_association.spoke](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0/docs/resources/nat_gateway_public_ip_association) | resource |
| [azurerm_network_security_group.hub](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.spoke](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.hub_deny_inbound](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.hub_deny_outbound](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.spoke_deny_inbound](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.spoke_deny_outbound](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0/docs/resources/network_security_rule) | resource |
| [azurerm_public_ip.nat](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0/docs/resources/public_ip) | resource |
| [azurerm_subnet.hub](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0/docs/resources/subnet) | resource |
| [azurerm_subnet.spoke](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0/docs/resources/subnet) | resource |
| [azurerm_subnet_nat_gateway_association.spoke](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0/docs/resources/subnet_nat_gateway_association) | resource |
| [azurerm_subnet_network_security_group_association.hub](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.spoke](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.hub](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network.spoke](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_peering.hub_to_spoke](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.spoke_to_hub](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0/docs/resources/virtual_network_peering) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_hub_address_space"></a> [hub\_address\_space](#input\_hub\_address\_space) | Hub virtual network CIDR. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Network name prefix. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Existing resource group name. | `string` | n/a | yes |
| <a name="input_spoke_address_space"></a> [spoke\_address\_space](#input\_spoke\_address\_space) | Spoke virtual network CIDR. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags. Environment, Owner and Project are required. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_hub_vnet_id"></a> [hub\_vnet\_id](#output\_hub\_vnet\_id) | Hub virtual network ID. |
| <a name="output_spoke_nat_gateway_id"></a> [spoke\_nat\_gateway\_id](#output\_spoke\_nat\_gateway\_id) | Spoke NAT gateway ID. |
| <a name="output_spoke_subnet_id"></a> [spoke\_subnet\_id](#output\_spoke\_subnet\_id) | Spoke workload subnet ID. |
| <a name="output_spoke_vnet_id"></a> [spoke\_vnet\_id](#output\_spoke\_vnet\_id) | Spoke virtual network ID. |
<!-- END_TF_DOCS -->
