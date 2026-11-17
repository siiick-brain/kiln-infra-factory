# Local-only runner for item 16. It mounts the host Docker socket, which gives it control of the
# host Docker daemon. Never run it in CI or on a shared host. See docs/kubernetes.md.
FROM docker:29.9.3-cli@sha256:5a7af0dcb0e46c803efe9b45371dd21cb500e5b4453250394ac6f06d49b6e6f1

ARG KIND_VERSION=0.29.0
ARG KUBECTL_VERSION=1.33.1

RUN set -eux; \
    apk add --no-cache bash curl; \
    cd /tmp; \
    curl -fsSLO "https://github.com/kubernetes-sigs/kind/releases/download/v${KIND_VERSION}/kind-linux-amd64"; \
    curl -fsSLO "https://github.com/kubernetes-sigs/kind/releases/download/v${KIND_VERSION}/kind-linux-amd64.sha256sum"; \
    sha256sum -c kind-linux-amd64.sha256sum; \
    install -m 0755 kind-linux-amd64 /usr/local/bin/kind; \
    curl -fsSLO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl"; \
    curl -fsSLo kubectl.sha256 "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"; \
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum -c -; \
    install -m 0755 kubectl /usr/local/bin/kubectl; \
    rm -f /tmp/kind-linux-amd64* /tmp/kubectl*

WORKDIR /workspace
