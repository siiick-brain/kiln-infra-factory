mock_provider "azurerm" {}

run "creates_separate_hub_and_spoke" {
  command = plan

  variables {
    name                = "test-net"
    resource_group_name = "rg-test"
    location            = "eastus"
    hub_address_space   = "10.10.0.0/16"
    spoke_address_space = "10.20.0.0/16"
    tags = {
      Environment = "test"
      Owner       = "siiick-brain"
      Project     = "kiln-infra-factory"
    }
  }

  assert {
    condition     = length(setintersection(azurerm_virtual_network.hub.address_space, azurerm_virtual_network.spoke.address_space)) == 0
    error_message = "Hub and spoke address ranges must differ."
  }

  assert {
    condition     = azurerm_network_security_rule.hub_deny_inbound.access == "Deny" && azurerm_network_security_rule.spoke_deny_inbound.access == "Deny"
    error_message = "Hub and spoke inbound firewall rules must deny by default."
  }

  assert {
    condition     = azurerm_network_security_rule.hub_deny_outbound.access == "Deny" && azurerm_network_security_rule.spoke_deny_outbound.access == "Deny"
    error_message = "Hub and spoke outbound firewall rules must deny by default."
  }

  assert {
    condition = alltrue([
      azurerm_network_security_rule.hub_deny_inbound.priority == 4096,
      azurerm_network_security_rule.spoke_deny_inbound.priority == 4096,
      azurerm_network_security_rule.hub_deny_outbound.priority == 4096,
      azurerm_network_security_rule.spoke_deny_outbound.priority == 4096,
      azurerm_network_security_rule.hub_deny_inbound.protocol == "*",
      azurerm_network_security_rule.spoke_deny_inbound.protocol == "*",
      azurerm_network_security_rule.hub_deny_outbound.protocol == "*",
      azurerm_network_security_rule.spoke_deny_outbound.protocol == "*"
    ])
    error_message = "All hub and spoke default-deny rules must cover every protocol at the default priority."
  }
}
