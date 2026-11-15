output "hub_vnet_id" {
  value       = azurerm_virtual_network.hub.id
  description = "Hub virtual network ID."
}

output "spoke_vnet_id" {
  value       = azurerm_virtual_network.spoke.id
  description = "Spoke virtual network ID."
}

output "spoke_subnet_id" {
  value       = azurerm_subnet.spoke.id
  description = "Spoke workload subnet ID."
}

output "spoke_nat_gateway_id" {
  value       = azurerm_nat_gateway.spoke.id
  description = "Spoke NAT gateway ID."
}
