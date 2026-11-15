FROM python:3.12-slim-trixie@sha256:1148dbb014615300fa7e713b2f94f550c0d1c69780c0805f84f093ceee34dd0b

ARG MOTO_VERSION=5.2.5
ARG DOCKER_PYTHON_VERSION=7.1.0

RUN python -m pip install --no-cache-dir \
    "docker==${DOCKER_PYTHON_VERSION}" \
    "moto[server]==${MOTO_VERSION}"

EXPOSE 5000

CMD ["moto_server", "-H", "0.0.0.0"]
