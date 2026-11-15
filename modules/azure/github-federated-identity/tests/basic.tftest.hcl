mock_provider "azurerm" {}

run "locks_federation_subject_to_repository_and_ref" {
  command = plan

  variables {
    name                = "github-test"
    resource_group_name = "rg-test"
    location            = "eastus"
    github_repository   = "example/repository"
    github_ref          = "refs/heads/main"
    tags = {
      Environment = "test"
      Owner       = "siiick-brain"
      Project     = "kiln-infra-factory"
    }
  }

  assert {
    condition     = azurerm_federated_identity_credential.github.subject == "repo:example/repository:ref:refs/heads/main"
    error_message = "Federation must require the exact repository and ref."
  }
}
