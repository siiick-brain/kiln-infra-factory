# Secure development lifecycle checklist

This checklist is informed by the practice areas of IEC 62443-4-1. It does not claim conformance to that standard or to any other. Statuses use the project words: Verified, Partial, Planned and Not covered.

| Practice area | Item | Status | Evidence |
|---------------|------|--------|----------|
| Security management | Roles for operator and approver are defined | Partial | [key-lifecycle.md](key-lifecycle.md). One person holds both roles |
| Security management | Tool and dependency versions are pinned and checked | Verified | `docker/toolbox/Dockerfile` checks SHA-256 for each download |
| Security management | Third-party components are listed with licences | Verified | [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md), [references.md](references.md) |
| Security requirements | Requirements are written as testable rules | Verified | `policies/terraform`, `policies/k8s`, [policy-catalog.md](policy-catalog.md) |
| Security requirements | Threats are identified per trust boundary | Verified | [threat-model.md](threat-model.md) |
| Secure by design | Defence in depth across network, identity and data | Partial | Default-deny network rules, OIDC trust conditions, encryption policies. Not deployed |
| Secure by design | Least privilege for automation identities | Verified | Wildcard rejection tests, [iam.md](iam.md) |
| Secure implementation | Coding and writing standards exist and are enforced | Verified | [bash-style.md](bash-style.md), [STYLE.md](STYLE.md), shellcheck, style checker |
| Secure implementation | Secrets are kept out of source | Verified | SOPS with age, gitleaks on tree and history |
| Verification and validation | Unit tests for every policy with a failing fixture | Verified | `opa test` results |
| Verification and validation | Static analysis of infrastructure code | Verified | Checkov and TFLint counts in the README |
| Verification and validation | Security tests for cryptographic functions | Verified | PKI and TPM bats tests |
| Verification and validation | Penetration or dynamic testing | Not covered | No running service is exposed |
| Defect management | Findings are recorded and triaged | Partial | Checkov skips carry justifications. No tracker |
| Defect management | Regression tests are added for fixed bugs | Verified | Regression tests exist for the commit hook, the style checker and the state verification |
| Security update management | Dependency update proposals | Planned | `dependabot.yml` in item 21 |
| Security update management | Hosts receive security updates | Partial | dnf-automatic configured. Timer Not verified in containers |
| Security guidelines | Operator procedures exist | Verified | [procedures/](procedures/) |
| Security guidelines | Hardening guidance for deployed hosts | Partial | [ansible.md](ansible.md) lists what the containers cannot test |
