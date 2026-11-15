# Glossary

| Use | Avoid | Meaning |
|-----|-------|---------|
| emulator | mock cloud, fake AWS | The local Moto server that answers AWS API calls. Nothing reaches a real account. |
| mock provider | stub, fake provider | A `mock_provider` block in a Terraform test that returns generated values without any API call. |
| module | component, package | A reusable Terraform directory under `modules/` with its own `VERSION`. |
| unit | stack, layer | One Terragrunt directory under `live/<env>/` that instantiates one module. |
| environment | tier | One of dev, stage or prod under `live/`. |
| pin | lock, tag (for module versions) | The module version recorded in `env.hcl` for an environment. |
| promotion | release, deploy | Copying a pin from one environment to the next after the gates pass. |
| gate | check, step (for promotion) | One command that must exit 0 before promotion edits a pin. |
| drift | configuration skew | A difference between recorded state and the emulator found by `terraform plan -detailed-exitcode`. |
| policy | rule set (in general prose) | A Rego package under `policies/` that denies an unsafe input. |
| finding | issue, alert | One failed check reported by Checkov, TFLint, Trivy or gitleaks. |
| accepted finding | ignored finding, suppression | A skipped check with a written justification in the tool config. |
| root CA | root cert | The self-signed ECDSA P-384 certificate authority kept in the ceremony volume. |
| intermediate CA | sub CA, issuing cert | The CA signed by the root with pathlen 0 that issues leaf certificates. |
| leaf certificate | end cert | A server or client certificate issued by the intermediate CA. |
| software TPM | virtual TPM, TPM (alone) | The swtpm process. It is not a hardware root of trust. |
| Verified | tested, works | The command ran, exited as expected and its log or artifact exists. |
| Not verified | untested, should work | The check did not run or did not finish. The reason is stated. |
| Planned | todo, future | Work that is designed but not built. |
| Not deployed | not live | Code that was never applied to a real cloud account. |
