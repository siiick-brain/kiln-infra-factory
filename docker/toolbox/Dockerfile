FROM python:3.12-slim-trixie@sha256:1148dbb014615300fa7e713b2f94f550c0d1c69780c0805f84f093ceee34dd0b

ARG DEBIAN_SNAPSHOT=20261029T000000Z
ARG TERRAFORM_VERSION=1.17.1
ARG TERRAGRUNT_VERSION=1.2.1
ARG TFLINT_VERSION=0.65.0
ARG CHECKOV_VERSION=3.4.0
ARG OPA_VERSION=1.22.0
ARG CONFTEST_VERSION=0.71.1
ARG ANSIBLE_VERSION=2.21.5
ARG ANSIBLE_LINT_VERSION=26.10.1
ARG SOPS_VERSION=3.13.3
ARG AGE_VERSION=1.3.2
ARG SHELLCHECK_VERSION=0.11.0
ARG BATS_VERSION=1.14.0
ARG TERRAFORM_DOCS_VERSION=0.24.0
ARG TPM2_TOOLS_VERSION=5.7-1
# These projects publish no checksum file for the assets used here. The hashes were recorded
# from the release downloads on 2026-11-15 and pin the exact files.
ARG AGE_SHA256=cbe24006683f8eb669266162894b9a522a1af52f2665fbc63a4bb032ed26ac10
ARG SHELLCHECK_SHA256=8c3be12b05d5c177a04c29e3c78ce89ac86f1595681cab149b65b97c4e227198
ARG BATS_SHA256=bb537b70b15b732f6d8827dd6578e3d8ce166636ce1f18ea9a074184fcce9177

ENV PATH="/opt/toolbox-venv/bin:/usr/local/bin:${PATH}"
WORKDIR /workspace

RUN set -eux; \
    rm -f /etc/apt/sources.list.d/debian.sources; \
    printf '%s\n' \
      "deb [check-valid-until=no] https://snapshot.debian.org/archive/debian/${DEBIAN_SNAPSHOT}/ trixie main" \
      "deb [check-valid-until=no] https://snapshot.debian.org/archive/debian-security/${DEBIAN_SNAPSHOT}/ trixie-security main" \
      > /etc/apt/sources.list; \
    apt-get -o Acquire::Check-Valid-Until=false update; \
    apt-get install -y --no-install-recommends \
      bash ca-certificates curl git jq openssh-client unzip xz-utils \
      tpm2-tools="${TPM2_TOOLS_VERSION}"; \
    python -m venv /opt/toolbox-venv; \
    pip install --no-cache-dir \
      "ansible-core==${ANSIBLE_VERSION}" \
      "ansible-lint==${ANSIBLE_LINT_VERSION}" \
      "pytest-testinfra==10.2.2" \
      "checkov==${CHECKOV_VERSION}"; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    mkdir -p /tmp/tool-downloads; \
    cd /tmp/tool-downloads; \
    curl -fsSLO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"; \
    curl -fsSLO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS"; \
    grep "terraform_${TERRAFORM_VERSION}_linux_amd64.zip$" "terraform_${TERRAFORM_VERSION}_SHA256SUMS" | sha256sum -c -; \
    unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -d /usr/local/bin; \
    curl -fsSLO "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64"; \
    curl -fsSLO "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/SHA256SUMS"; \
    grep 'terragrunt_linux_amd64$' SHA256SUMS | sha256sum -c -; \
    install -m 0755 terragrunt_linux_amd64 /usr/local/bin/terragrunt; \
    curl -fsSLO "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip"; \
    curl -fsSLO "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/checksums.txt"; \
    grep "tflint_linux_amd64.zip$" checksums.txt | sha256sum -c -; \
    unzip tflint_linux_amd64.zip -d /usr/local/bin; \
    rm -rf /tmp/tool-downloads

RUN set -eux; \
    mkdir -p /tmp/tool-downloads; \
    cd /tmp/tool-downloads; \
    curl -fsSLo /usr/local/bin/opa "https://openpolicyagent.org/downloads/v${OPA_VERSION}/opa_linux_amd64_static"; \
    curl -fsSLo opa.sha256 "https://openpolicyagent.org/downloads/v${OPA_VERSION}/opa_linux_amd64_static.sha256"; \
    expected_opa_sha="$(awk '{print $1}' opa.sha256)"; \
    actual_opa_sha="$(sha256sum /usr/local/bin/opa | awk '{print $1}')"; \
    test "$expected_opa_sha" = "$actual_opa_sha"; \
    chmod 0755 /usr/local/bin/opa; \
    curl -fsSLO "https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz"; \
    curl -fsSLO "https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/checksums.txt"; \
    grep "conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz$" checksums.txt | sha256sum -c -; \
    tar -xzf "conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz" -C /usr/local/bin conftest; \
    rm -rf /tmp/tool-downloads

RUN set -eux; \
    mkdir -p /tmp/tool-downloads; \
    cd /tmp/tool-downloads; \
    curl -fsSLO "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64"; \
    curl -fsSLO "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.checksums.txt"; \
    grep "sops-v${SOPS_VERSION}.linux.amd64$" "sops-v${SOPS_VERSION}.checksums.txt" | sha256sum -c -; \
    install -m 0755 "sops-v${SOPS_VERSION}.linux.amd64" /usr/local/bin/sops; \
    curl -fsSLO "https://github.com/FiloSottile/age/releases/download/v${AGE_VERSION}/age-v${AGE_VERSION}-linux-amd64.tar.gz";     echo "${AGE_SHA256}  age-v${AGE_VERSION}-linux-amd64.tar.gz" | sha256sum -c -; \
    tar -xzf "age-v${AGE_VERSION}-linux-amd64.tar.gz"; \
    install -m 0755 age/age age/age-keygen /usr/local/bin/; \
    curl -fsSLO "https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz";     echo "${SHELLCHECK_SHA256}  shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz" | sha256sum -c -; \
    tar -xJf "shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz"; \
    install -m 0755 "shellcheck-v${SHELLCHECK_VERSION}/shellcheck" /usr/local/bin/shellcheck; \
    curl -fsSL "https://github.com/bats-core/bats-core/archive/refs/tags/v${BATS_VERSION}.tar.gz" -o bats-core.tar.gz;     echo "${BATS_SHA256}  bats-core.tar.gz" | sha256sum -c -; \
    tar -xzf bats-core.tar.gz; \
    "./bats-core-${BATS_VERSION}/install.sh" /usr/local; \
    curl -fsSLO "https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz"; \
    curl -fsSLO "https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}.sha256sum"; \
    grep "terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz$" "terraform-docs-v${TERRAFORM_DOCS_VERSION}.sha256sum" | sha256sum -c -; \
    tar -xzf "terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz" -C /usr/local/bin terraform-docs; \
    rm -rf /tmp/tool-downloads

ARG KUBECONFORM_VERSION=0.6.7
RUN set -eux; \
    mkdir -p /tmp/tool-downloads; \
    cd /tmp/tool-downloads; \
    curl -fsSLO "https://github.com/yannh/kubeconform/releases/download/v${KUBECONFORM_VERSION}/kubeconform-linux-amd64.tar.gz"; \
    curl -fsSLO "https://github.com/yannh/kubeconform/releases/download/v${KUBECONFORM_VERSION}/CHECKSUMS"; \
    grep "kubeconform-linux-amd64.tar.gz$" CHECKSUMS | sha256sum -c -; \
    tar -xzf kubeconform-linux-amd64.tar.gz -C /usr/local/bin kubeconform; \
    rm -rf /tmp/tool-downloads
