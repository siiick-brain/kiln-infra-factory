# References

Upstream release tags, repository licence metadata and last-push timestamps were checked against first-party GitHub or Debian sources on 2026-10-30. Versions in the toolbox are fixed in its Dockerfile. Docker Engine is available. The toolbox image build and tool execution are not verified yet.

| Tool | Pinned version | Licence | Source | Last push or package check |
|---|---:|---|---|---|
| Terraform | 1.17.1 | BUSL-1.1, with MPL-2.0 change license | [README](https://github.com/hashicorp/terraform) and [LICENSE](https://github.com/hashicorp/terraform/blob/main/LICENSE) | 2026-10-30 14:28 UTC |
| Terragrunt | 1.2.1 | MIT | [README](https://github.com/gruntwork-io/terragrunt) and [LICENSE](https://github.com/gruntwork-io/terragrunt/blob/main/LICENSE) | 2026-10-29 22:09 UTC |
| TFLint | 0.65.0 | MPL-2.0 | [README](https://github.com/terraform-linters/tflint) and [LICENSE](https://github.com/terraform-linters/tflint/blob/master/LICENSE) | 2026-10-28 02:05 UTC |
| Checkov | 3.4.0 | Apache-2.0 | [README](https://github.com/bridgecrewio/checkov) and [LICENSE](https://github.com/bridgecrewio/checkov/blob/main/LICENSE) | 2026-10-29 12:38 UTC |
| OPA | 1.22.0 | Apache-2.0 | [README](https://github.com/open-policy-agent/opa) and [LICENSE](https://github.com/open-policy-agent/opa/blob/main/LICENSE) | 2026-10-30 13:35 UTC |
| Conftest | 0.71.1 | Apache-2.0 | [README](https://github.com/open-policy-agent/conftest) and [LICENSE](https://github.com/open-policy-agent/conftest/blob/master/LICENSE) | 2026-10-29 16:41 UTC |
| actions/checkout | v7.0.1 at `3d3c42e5aac5ba805825da76410c181273ba90b1` | MIT | [README](https://github.com/actions/checkout/tree/v7.0.1) and [LICENSE](https://github.com/actions/checkout/blob/v7.0.1/LICENSE) | 2026-11-16 |
| Ansible Core | 2.21.5 | GPL-3.0-or-later | [README](https://github.com/ansible/ansible) and [COPYING](https://github.com/ansible/ansible/blob/devel/COPYING) | 2026-10-28 22:38 UTC |
| Ansible Lint | 26.10.1 | GPL-3.0-or-later | [README](https://github.com/ansible/ansible-lint) and [COPYING](https://github.com/ansible/ansible-lint/blob/main/COPYING) | 2026-10-30 09:42 UTC |
| pytest-testinfra | 10.2.2 | Apache-2.0 | [README](https://github.com/pytest-dev/pytest-testinfra/blob/main/README.rst) and [LICENSE](https://github.com/pytest-dev/pytest-testinfra/blob/main/LICENSE) | 2026-07-20 |
| SOPS | 3.13.3 | MPL-2.0 | [README](https://github.com/getsops/sops) and [LICENSE](https://github.com/getsops/sops/blob/main/LICENSE) | 2026-10-27 17:22 UTC |
| age | 1.3.2 | BSD-3-Clause | [README](https://github.com/FiloSottile/age) and [LICENSE](https://github.com/FiloSottile/age/blob/main/LICENSE) | 2026-08-29 17:55 UTC |
| ShellCheck | 0.11.0 | GPL-3.0-or-later | [README](https://github.com/koalaman/shellcheck) and [LICENSE](https://github.com/koalaman/shellcheck/blob/master/LICENSE) | 2026-10-26 01:55 UTC |
| bats-core | 1.14.0 | MIT | [README](https://github.com/bats-core/bats-core) and [LICENSE](https://github.com/bats-core/bats-core/blob/master/LICENSE) | 2026-10-27 19:04 UTC |
| terraform-docs | 0.24.0 | MIT | [README](https://github.com/terraform-docs/terraform-docs) and [LICENSE](https://github.com/terraform-docs/terraform-docs/blob/master/LICENSE) | 2026-09-02 08:09 UTC |
| tpm2-tools | 5.7-1 (Debian Trixie package) | BSD-3-Clause SPDX header in source files; no root licence file found | [README](https://github.com/tpm2-software/tpm2-tools) and [Debian package](https://packages.debian.org/trixie/tpm2-tools) | Package candidate checked 2026-10-30 |
| Moto server | 5.2.5 | Apache-2.0 | [README](https://github.com/getmoto/moto) and [LICENSE](https://github.com/getmoto/moto/blob/master/LICENSE) | 2026-10-30 05:48 UTC |
| kubeconform | 0.6.7 | Apache-2.0 | [README](https://github.com/yannh/kubeconform) and [LICENSE](https://github.com/yannh/kubeconform/blob/master/LICENSE) | 2026-06-13 push, checked 2026-11-15 |
| kind | 0.29.0 | Apache-2.0 | [README](https://github.com/kubernetes-sigs/kind) and [LICENSE](https://github.com/kubernetes-sigs/kind/blob/main/LICENSE) | 2026-11-13 push, checked 2026-11-15 |
| kubectl | 1.33.1 | Apache-2.0 | [Kubernetes release binaries](https://kubernetes.io/releases/download/) | checked 2026-11-15 |
| swtpm | 0.7.1-1.5 (Debian Trixie package) | BSD-3-Clause | [README](https://github.com/stefanberger/swtpm) and [LICENSE](https://github.com/stefanberger/swtpm/blob/master/LICENSE) | 2026-11-02 push, checked 2026-11-15 |
| OpenSSL | 3.5.7 (Debian package in the toolbox) | Apache-2.0 | [README](https://github.com/openssl/openssl) and [LICENSE](https://github.com/openssl/openssl/blob/master/LICENSE.txt) | 2026-11-14 push, checked 2026-11-15 |

## Cloud service documentation

- [Azure Key Vault RBAC guide](https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide), checked on 2026-10-30 for secret-level scope support and role assignment guidance.

The pytest-testinfra README warns that the project is not actively maintained. The dependency is pinned and used only against disposable local Rocky containers. Its checks are limited to the requested target configuration.

| Terraform provider | Pinned version | Registry source |
|---|---:|---|
| AWS | 6.71.0 | [Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/6.71.0) |
| AzureRM | 5.12.0 | [Terraform Registry](https://registry.terraform.io/providers/hashicorp/azurerm/5.12.0) |
| Google | 8.9.0 | [Terraform Registry](https://registry.terraform.io/providers/hashicorp/google/8.9.0) |

## Reference projects

Each project was read for its README and licence before use. No text or code was copied.

| Project | Licence | Used for | Status |
|---|---|---|---|
| [MicrosoftDocs/cloud-adoption-framework](https://github.com/MicrosoftDocs/cloud-adoption-framework) | CC-BY-4.0 | Design area names in the Azure landing zone map | Used |
| [kelseyhightower/kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way) | Apache-2.0 | The list of component certificates a cluster needs | Used |
| [livialima/linuxupskillchallenge](https://github.com/livialima/linuxupskillchallenge) | CC-BY-4.0 | Topic outline for the Linux administration exercises | Used |
| [Idnan/bash-guide](https://github.com/Idnan/bash-guide) | MIT | General shell reference while writing the bash style rules | Used as reference only |
| [donnemartin/system-design-primer](https://github.com/donnemartin/system-design-primer) | CC-BY-4.0 (licence file text) | Background reading on availability trade-offs | Used as reference only |
| [ChiefGyk3D/Clouds-Against-Humanity](https://github.com/ChiefGyk3D/Clouds-Against-Humanity) | Apache-2.0 | Zero trust principle list mapped to controls | Used |
| [floci-io/floci](https://github.com/floci-io/floci) | MIT | Emulator candidate | Evaluated, not used. See below |

## Evaluated but not used

| Project | Decision | Evidence |
|---|---|---|
| floci | Not used. Its README states it needs no account or auth token and it serves S3, SQS, Lambda, IAM and STS on one port. It was evaluated on 2026-11-15, after every emulator test was built and verified on Moto. Switching would repeat that work for no gain in coverage. | [README](https://github.com/floci-io/floci) checked 2026-11-15 |
| LocalStack | Not used. Its current installation path requires an Auth Token and browser login. | [Installation and authentication requirements](https://docs.localstack.cloud/aws/getting-started/installation/) |

## Container image references

- Toolbox and Moto base: [`python:3.12-slim-trixie@sha256:1148dbb014615300fa7e713b2f94f550c0d1c69780c0805f84f093ceee34dd0b`](https://hub.docker.com/layers/library/python/3.12-slim-trixie/images/sha256-1148dbb014615300fa7e713b2f94f550c0d1c69780c0805f84f093ceee34dd0b)
- swtpm base: [`debian:trixie-slim@sha256:1e1a22175fbf1b32157ddaf0219e1db4e5401fab2b94ed285add64d18587cd2d`](https://hub.docker.com/layers/library/debian/trixie-slim/images/sha256-1e1a22175fbf1b32157ddaf0219e1db4e5401fab2b94ed285add64d18587cd2d)
- Rocky Linux targets: [`quay.io/rockylinux/rockylinux:9.8@sha256:8101994123cf3d0a8fee517bee7f39e555c7d92bd2d9eb3303cc988a0eeed00f`](https://quay.io/repository/rockylinux/rockylinux?tab=tags)
- kind-runner base: [`docker:27.5.1-cli@sha256:851f91d241214e7c6db86513b270d58776379aacc5eb9c4a87e5b47115e3065c`](https://hub.docker.com/_/docker)
- kind node: [`kindest/node:v1.33.1@sha256:050072256b9a903bd914c0b2866828150cb229cea0efe5892e2b644d5dd3b34f`](https://hub.docker.com/r/kindest/node)
- Sample workload: [`nginxinc/nginx-unprivileged:1.27.5-alpine@sha256:65e3e85dbaed8ba248841d9d58a899b6197106c23cb0ff1a132b7bfe0547e4c0`](https://hub.docker.com/r/nginxinc/nginx-unprivileged)
