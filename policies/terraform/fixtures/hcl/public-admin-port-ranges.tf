resource "google_compute_firewall" "public_admin_range" {
  project       = "test-project"
  name          = "public-admin-range"
  network       = "test-network"
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }
}

resource "google_compute_firewall" "public_admin_all_ports" {
  project       = "test-project"
  name          = "public-admin-all-ports"
  network       = "test-network"
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
  }
}

resource "azurerm_network_security_rule" "public_admin_range" {
  name                        = "public-admin-range"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1-65535"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = "test-rg"
  network_security_group_name = "test-nsg"
}

resource "azurerm_network_security_rule" "public_admin_ranges" {
  name                        = "public-admin-ranges"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["1-65535"]
  source_address_prefixes     = ["Internet"]
  destination_address_prefix  = "*"
  resource_group_name         = "test-rg"
  network_security_group_name = "test-nsg"
}
