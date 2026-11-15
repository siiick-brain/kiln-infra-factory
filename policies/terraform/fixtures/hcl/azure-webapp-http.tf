resource "azurerm_linux_web_app" "bad" {
  name                = "test-webapp"
  resource_group_name = "test-rg"
  location            = "eastus"
  service_plan_id     = "test-plan"
  https_only          = false

  site_config {
    minimum_tls_version = "1.0"
  }

  tags = {
    Environment = "test"
    Owner       = "siiick-brain"
    Project     = "kiln-infra-factory"
  }
}
