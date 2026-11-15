# Documentation index

## Start here

| Document | Content |
|----------|---------|
| [STYLE.md](STYLE.md) | Writing rules and how they are enforced |
| [GLOSSARY.md](GLOSSARY.md) | Terms to use and terms to avoid |
| [skills-evidence.md](skills-evidence.md) | Each skill and the file, test or run that proves it |
| [references.md](references.md) | Tools, versions, licences and reference projects |

## Infrastructure

| Document | Content | Test commands |
|----------|---------|---------------|
| [networking.md](networking.md) | Diagrams and rule tables for AWS, Azure and GCP | `scripts/test-modules.sh`, `opa test policies/terraform` |
| [iam.md](iam.md) | Every permission and why it exists | `scripts/test-modules.sh` |
| [state.md](state.md) | Remote state, locking and secrets in state | `scripts/migrate-state.sh` |
| [promotion.md](promotion.md) | Pinned versions and gates | `tests/test_promote.ps1` |
| [drift.md](drift.md) | Drift detection on the emulator | `scripts/drift-demo.sh` |
| [secrets.md](secrets.md) | SOPS with age and cloud secret stores | `tests/test_sops.ps1` |
| [policy-catalog.md](policy-catalog.md) | Each policy rule mapped to its control | `opa test policies` |
| [azure-landing-zone-map.md](azure-landing-zone-map.md) | Cloud Adoption Framework design areas mapped to modules | static checks only |

## Hosts, Kubernetes and keys

| Document | Content | Test commands |
|----------|---------|---------------|
| [ansible.md](ansible.md) | Roles, idempotence and container limits | `scripts/test-ansible.ps1` |
| [linux-admin.md](linux-admin.md) | 20 exercises with saved output | `scripts/linux-exercises.sh` |
| [bash-style.md](bash-style.md) | Shell rules | `bats tests/test_bash_conventions.bats` |
| [kubernetes.md](kubernetes.md) | Restricted workload on kind | `k8s/kind-apply.sh` |
| [pki.md](pki.md) | CA hierarchy, profiles, CRL, OCSP and rotation | `bats tests/test_pki.bats` |
| [tpm.md](tpm.md) | Software TPM seal, quote and NV counter | `scripts/test-tpm.ps1` |
| [key-lifecycle.md](key-lifecycle.md) | Generation to destruction for every key class | review |

## Security and process

| Document | Content |
|----------|---------|
| [threat-model.md](threat-model.md) | STRIDE, trust boundaries and attack trees |
| [risk-assessment.md](risk-assessment.md) | Risk register with treatment and residual risk |
| [sdl-checklist.md](sdl-checklist.md) | Lifecycle checklist informed by IEC 62443-4-1 |
| [zero-trust.md](zero-trust.md) | Principles mapped to controls |
| [procedures/](procedures/) | Instruction manuals for routine and emergency tasks |
| [runbooks/](runbooks/) | Short incident runbooks |
| [adr/](adr/) | Architecture decision records |
| [repo-metadata.md](repo-metadata.md) | Values for the GitHub repository settings |
