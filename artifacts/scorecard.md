# Scorecard

Honest status per spec item, updated 2026-11-18. Pass means the named command ran and its log or artifact exists. Every row links to evidence in the repository or names the log in `artifacts/logs/` that holds it.

| Item | Area | Status | Evidence |
|------|------|--------|----------|
| 0 | Foundations, hook, style checker | Verified | `tests/test_commit_hook.bats` 5 of 5, `tests/test_style_checker.ps1` 8 of 8 |
| 1 | Toolbox and emulator | Verified | `scripts/tb.ps1 versions` 16 tools, emulator health 200, [ADR 0001](../docs/adr/0001-emulator-choice.md) |
| 2 | AWS modules | Verified (mock and emulator) | `scripts/test-modules.sh`, dev units applied to Moto |
| 3 | Azure modules | Verified (static and mock only) | validate and mock tests, Checkov, OPA |
| 4 | GCP modules | Verified (static and mock only) | validate and mock tests, Checkov, OPA |
| 5 | Secrets | Verified | `tests/test_sops.bats` 3 of 3, gitleaks clean |
| 6 | Remote state and locking | Verified on the emulator | `scripts/migrate-state.sh`: state verified, second apply refused |
| 7 | Terragrunt run-all | Verified on the emulator | 2026-11-17: validate for all 21 units, then plan, apply and destroy for the AWS units of dev, stage and prod in one 41 minute run. Step logs in `artifacts/logs/terragrunt/`. The earlier hours-long stage applies were Terraform waiting for `RedriveAllowPolicy`, which Moto does not return ([ADR 0001](../docs/adr/0001-emulator-choice.md)) |
| 8 | Promotion | Verified on the emulator | 2026-11-18: `scripts/promote.ps1 -From dev -To stage` ran all seven gates for real and wrote the pin. Log `artifacts/logs/promotion-dev-stage.log`. Gate logic also tested with stubs |
| 9 | Drift detection | Partial | Exit 2 and the diff Verified. The scheduled drift workflow passes on main: `scripts/drift-classify.sh` finds no drift outside two known Moto artifacts (policy JSON whitespace, bucket tags dropped on create). A raw plan exit 0 is Not verified on Moto |
| 10 | OPA and Rego | Verified | `opa test` 34 of 34. Bad HCL fixtures give 12 denials |
| 11 | Checkov and TFLint | Verified | Checkov 0 failed with 34 justified skips. TFLint 0 findings in 34 directories |
| 12 | Networking | Verified | [networking.md](../docs/networking.md), default-deny tests |
| 13 | Workload identity and IAM | Verified (mock) | OIDC and GKE module tests, wildcard rejection tests |
| 14 | Ansible and Rocky Linux | Verified | Rocky Linux 10.2 targets, toolbox on Python 3.15 with ansible-core 2.22.0: second run changed=0, testinfra 16 passed, ansible-lint production profile |
| 15 | Bash | Verified | `tests/test_bash_conventions.bats` 5 of 5, shellcheck 0 findings |
| 16 | Kubernetes with kind | Verified | kind 7 PASS, kubeconform 6 valid, Conftest 72 passed |
| 17 | PKI | Verified | `tests/test_pki.bats` 12 of 12, rotation deploy 5 of 5 |
| 18 | Kubernetes certificates | Verified | `tests/test_pki_k8s.bats` 8 of 8 |
| 19 | TPM and key lifecycle | Verified on swtpm | `tests/test_tpm.bats` 6 of 6. swtpm is not a hardware root of trust |
| 20 | Cross-project documents | Done | threat model, risk register, SDL checklist, 5 procedures, maps, references |
| 21 | CI | Verified | CI and Encrypted example pass on main on GitHub Actions. Actions pinned by SHA |
| 22 | Docs and media | Partial | README, 6 ADRs, 5 runbooks. 9 diagram PNGs rendered with mermaid-cli 12.2.0. The explainer video is Not verified |
| 23 | Screenshots | Verified | Terminal images and 5 public GitHub page captures in [docs/screenshots.md](../docs/screenshots.md) |
| 24 | Skills gate | See [skills report](skills-report.md) | `scripts/verify-skills.ps1 -Strict` |

## Not verified, with cause

- Lambda delivery from SQS: Moto stores functions but the emulator no longer has a Docker socket to run them.
- Drift exit 0: Moto returns policy JSON with spaces, so every plan shows a whitespace-only diff.
- The explainer video: not produced.
- Real cloud deployment: never attempted by design.
