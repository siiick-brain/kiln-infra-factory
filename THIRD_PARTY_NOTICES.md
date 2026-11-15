# Third-party notices

The toolbox downloads the upstream tools listed in [the reference register](docs/references.md) at fixed versions. The local image is built from pinned Python, Debian and Rocky Linux image digests.

Terraform 1.17.1 is under BUSL-1.1 with the additional use grant and a change license of MPL-2.0 four years after the version is first publicly distributed. This repository uses Terraform only for local testing and emulator-backed plans. It does not host Terraform as a service or use it for production deployment.

Ansible Core, Ansible Lint and ShellCheck are GPL-3.0-or-later. SOPS and TFLint are MPL-2.0. The remaining tools use the licences listed in the reference register. Source repositories provide the full licence texts and required notices.

No upstream source code is copied into this repository.
