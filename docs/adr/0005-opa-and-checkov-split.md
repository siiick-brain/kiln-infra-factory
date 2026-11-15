# ADR 0005: OPA and Checkov split

## Status

Accepted, 2026-10-30

## Context

Checkov ships hundreds of generic checks. Some project rules are specific, such as required tags, allowed regions and OIDC trust conditions. Generic checks cannot express them.

## Decision

- Checkov covers generic misconfiguration across all modules and live units. Every skipped check carries a written justification.
- OPA with Rego covers project rules in `policies/`. Each rule has a unit test and a failing fixture that proves it denies.
- AWS units are checked on emulator plan JSON. Azure and GCP modules are checked on HCL with `conftest --parser hcl2`, because they never reach plan.
- Kubernetes manifests are checked by Conftest rules in `policies/k8s`.

## Consequences

- Two tools run in CI. Their findings are counted separately.
- HCL parsing sees the written configuration, not computed values, so HCL rules are written to be conservative.
- A clean scan shows only that these checks found nothing. It does not prove the configuration is secure.
