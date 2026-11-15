# Risk assessment

Likelihood and impact use a 1 to 5 scale. Risk is likelihood times impact. Treatment is one of Mitigate, Accept, Transfer or Avoid. Residual risk is the score after the listed controls. Scores are the author's judgement for a small team running this design. They are not measured.

## Register

| ID | Risk | L | I | Score | Treatment | Controls | Residual L | Residual I | Residual |
|----|------|---|---|-------|-----------|----------|------------|------------|----------|
| R1 | Intermediate CA key stolen from the host | 2 | 5 | 10 | Mitigate | Volume not backed up, short leaf lifetime, CRL and OCSP, CA compromise procedure | 1 | 5 | 5 |
| R2 | Root CA key exposed | 1 | 5 | 5 | Mitigate | Offline volume, two-person ceremony, locked media | 1 | 5 | 5 |
| R3 | Secrets read from Terraform state | 3 | 4 | 12 | Mitigate | Encrypted bucket, least-privilege state access, secrets kept out of variables where possible, gitleaks | 2 | 4 | 8 |
| R4 | Concurrent applies corrupt state | 3 | 3 | 9 | Mitigate | S3 lock file, versioned bucket, state recovery procedure | 1 | 3 | 3 |
| R5 | CI role used by another repository or branch | 2 | 5 | 10 | Mitigate | OIDC trust bound to repository and ref, tested in all three clouds | 1 | 5 | 5 |
| R6 | Over-privileged IAM in a module | 3 | 4 | 12 | Mitigate | Wildcard rejection in OPA and module tests, documented permissions in iam.md | 2 | 3 | 6 |
| R7 | Unreviewed module version reaches prod | 2 | 4 | 8 | Mitigate | Promotion gates, prod refuses a pin that stage does not run, manual commit | 1 | 4 | 4 |
| R8 | Configuration drift goes unnoticed | 3 | 3 | 9 | Mitigate | Scheduled drift workflow with exit code 2 failure | 2 | 3 | 6 |
| R9 | Compromised upstream action or image | 2 | 5 | 10 | Mitigate | Full SHA and digest pins, Dependabot proposals applied by hand | 2 | 4 | 8 |
| R10 | age key lost | 2 | 3 | 6 | Mitigate | One offline backup, rotation procedure | 1 | 3 | 3 |
| R11 | kind-runner socket mount abused | 2 | 4 | 8 | Accept | Local profile only, read-only repository mount, never in CI | 2 | 4 | 8 |
| R12 | Emulator behaviour differs from AWS | 4 | 3 | 12 | Accept | Results labelled emulator only. Real deployment Planned | 4 | 3 | 12 |
| R13 | Software TPM mistaken for hardware assurance | 2 | 3 | 6 | Mitigate | Every TPM document and test states swtpm is software | 1 | 3 | 3 |
| R14 | Single author holds operator and approver roles | 5 | 3 | 15 | Accept | Stated limitation. Reviews done in a fresh context against the diff | 5 | 3 | 15 |

## Accepted risks

- R11: the socket mount is needed to create a kind cluster from a container. It stays on the workstation.
- R12: the project must not touch a real account. Emulator gaps are listed in [ADR 0001](adr/0001-emulator-choice.md).
- R14: this is a portfolio repository with one author.

## Review

Review this register when a module, a key class or a workflow is added and at least every 6 months.
