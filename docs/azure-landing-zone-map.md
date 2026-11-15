# Azure landing zone map

The design area names come from the Microsoft Cloud Adoption Framework landing zone guidance ([MicrosoftDocs/cloud-adoption-framework](https://github.com/MicrosoftDocs/cloud-adoption-framework), CC-BY-4.0). Each area is mapped to the modules in this repository. Nothing was deployed to Azure. Every row is checked by `terraform validate`, mock-provider tests, Checkov and OPA only.

| Design area | What this repository provides | Module or file | Coverage |
|-------------|-------------------------------|----------------|----------|
| Azure billing and Microsoft Entra tenant | Nothing. Tenant and billing setup need a real account | none | Not covered |
| Identity and access management | Federated identity for GitHub Actions bound to one repository and ref. Managed identity for the app | `modules/azure/github-federated-identity`, `modules/azure/hosting` | Partial |
| Resource organization | Required tags (Environment, Owner, Project) validated on every module | variable validation, `policies/terraform` required tags rule | Partial |
| Network topology and connectivity | Hub and spoke VNets, peering, NSGs with deny rules, NAT gateway | `modules/azure/net-hub-spoke`, [networking.md](networking.md) | Implemented |
| Security | HTTPS only, TLS 1.2 minimum, Key Vault with public network access disabled, policy as code | `modules/azure/hosting`, `modules/azure/keyvault`, `policies/terraform` | Implemented |
| Management | Diagnostic settings for the app to a Log Analytics workspace | `modules/azure/hosting` | Partial |
| Governance | Policy as code in CI instead of Azure Policy assignments | `policies/terraform`, Checkov | Partial |
| Platform automation and DevOps | Terragrunt environments, pinned module promotion, drift detection, CI | `live/`, `scripts/promote.ps1`, `.github/workflows` | Implemented (emulator and static checks) |

## Not covered

- Management group hierarchy and subscription vending.
- Azure Policy assignments and initiatives.
- Private DNS zones and private endpoints in the hub (Key Vault private endpoint is Planned).
- Azure Firewall in the hub. NSGs and the NAT gateway are used instead.
