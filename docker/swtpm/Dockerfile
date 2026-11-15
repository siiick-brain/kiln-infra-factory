FROM debian:trixie-slim@sha256:1e1a22175fbf1b32157ddaf0219e1db4e5401fab2b94ed285add64d18587cd2d

ARG DEBIAN_SNAPSHOT=20261029T000000Z
ARG SWTPM_VERSION=0.10.2-2

RUN set -eux; \
    rm -f /etc/apt/sources.list.d/debian.sources; \
    printf '%s\n' \
      "deb [check-valid-until=no] https://snapshot.debian.org/archive/debian/${DEBIAN_SNAPSHOT}/ trixie main" \
      "deb [check-valid-until=no] https://snapshot.debian.org/archive/debian-security/${DEBIAN_SNAPSHOT}/ trixie-security main" \
      > /etc/apt/sources.list; \
    apt-get -o Acquire::Check-Valid-Until=false update; \
    apt-get install -y --no-install-recommends "swtpm=${SWTPM_VERSION}"; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p /var/lib/swtpm; \
    chown 10001:10001 /var/lib/swtpm

USER 10001:10001
VOLUME ["/var/lib/swtpm"]
EXPOSE 2321 2322

CMD ["swtpm", "socket", "--tpm2", "--tpmstate", "dir=/var/lib/swtpm", "--server", "type=tcp,port=2321,bindaddr=0.0.0.0", "--ctrl", "type=tcp,port=2322,bindaddr=0.0.0.0", "--flags", "not-need-init,startup-clear"]
