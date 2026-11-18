# Screenshots

Each image is rendered by `scripts/terminal_shot.py` from the real output and exit code of the command shown at its top. Text is not edited except redaction of emails, tokens, account IDs and URLs. The footer states how many values were redacted. "Recorded run" images show lines from a log in `artifacts/logs` written by the named run. `scripts/capture-all.ps1` renders them all again.

The public GitHub pages at the end are captured unedited by `scripts/capture_github.py` (Playwright, signed out, 1440 by 900). The architecture explainer video is Not verified.

## tb-versions

Pinned tool versions in the toolbox (live)

![Pinned tool versions in the toolbox (live)](images/tb-versions.png)

## tf-validate-all

fmt, validate and examples for 17 modules (recorded run)

![fmt, validate and examples for 17 modules (recorded run)](images/tf-validate-all.png)

## terraform-test

terraform test per module (recorded run)

![terraform test per module (recorded run)](images/terraform-test.png)

## checkov-summary

Checkov: 687 passed, 0 failed, 34 accepted skips (recorded run)

![Checkov: 687 passed, 0 failed, 34 accepted skips (recorded run)](images/checkov-summary.png)

## conftest-pass

Conftest on modules and live (live)

![Conftest on modules and live (live)](images/conftest-pass.png)

## conftest-deny

Conftest denies the bad HCL fixtures (live)

![Conftest denies the bad HCL fixtures (live)](images/conftest-deny.png)

## terragrunt-plan

Terragrunt validate for all three environments, then plan, apply and destroy of the dev AWS units (recorded run). stage and prod apply are Not verified

![Terragrunt run-all for dev, stage and prod (recorded run)](images/terragrunt-plan.png)

## remote-state

State migration and lock refusal on the emulator (recorded run)

![State migration and lock refusal on the emulator (recorded run)](images/remote-state.png)

## drift-detected

Drift demo with exit code 2 and the classified final plan (recorded run)

![Drift demo with exit code 2 and the classified final plan (recorded run)](images/drift-detected.png)

## promotion-gates

Promotion gate tests with stubbed gate commands (live)

![Promotion gate tests with stubbed gate commands (live)](images/promotion-gates.png)

## ansible-recap

Ansible recap, lint and testinfra (recorded run)

![Ansible recap, lint and testinfra (recorded run)](images/ansible-recap.png)

## pki-chain-verify

PKI tests (live)

![PKI tests (live)](images/pki-chain-verify.png)

## pki-revoked-crl

Revoked certificate fails the CRL check (live)

![Revoked certificate fails the CRL check (live)](images/pki-revoked-crl.png)

## ocsp-revoked

OCSP reports revoked and good (live)

![OCSP reports revoked and good (live)](images/ocsp-revoked.png)

## cert-rotation

Rotation deployed to nginx with a graceful reload (recorded run)

![Rotation deployed to nginx with a graceful reload (recorded run)](images/cert-rotation.png)

## tpm-unseal-ok

TPM tests on swtpm (recorded run)

![TPM tests on swtpm (recorded run)](images/tpm-unseal-ok.png)

## tpm-unseal-fail

Unseal fails after a PCR extend (recorded run)

![Unseal fails after a PCR extend (recorded run)](images/tpm-unseal-fail.png)

## sops-encrypted

Committed SOPS file is encrypted (live)

![Committed SOPS file is encrypted (live)](images/sops-encrypted.png)

## kind-apply

kind apply and pod checks (recorded run)

![kind apply and pod checks (recorded run)](images/kind-apply.png)

## k8s-certs-verify

Kubernetes component certificates (live)

![Kubernetes component certificates (live)](images/k8s-certs-verify.png)

## tests-green

Summary line of each test suite (recorded runs)

![Summary line of each test suite (recorded runs)](images/tests-green.png)

## secret-scan

gitleaks on history and tree (live)

![gitleaks on history and tree (live)](images/secret-scan.png)

## skills-report

Skills gate (live)

![Skills gate (live)](images/skills-report.png)

## GitHub pages

Captured on 2026-11-18 with `python scripts/capture_github.py`, signed out.

### github-ci-green

CI runs on main

![CI runs on main](images/github-ci-green.png)

### github-drift-workflow

Emulator drift workflow on main

![Emulator drift workflow on main](images/github-drift-workflow.png)

### github-readme-top

Repository page with description and topics

![Repository page](images/github-readme-top.png)

### github-readme-architecture

Architecture diagram as GitHub renders the README

![README architecture section](images/github-readme-architecture.png)

### github-contributors

Contributors graph: one author

![Contributors graph](images/github-contributors.png)
