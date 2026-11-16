FROM python:3.12-slim-trixie@sha256:1148dbb014615300fa7e713b2f94f550c0d1c69780c0805f84f093ceee34dd0b

COPY docker/emulator/requirements.txt /tmp/requirements.txt
RUN python -m pip install --no-cache-dir -r /tmp/requirements.txt && rm /tmp/requirements.txt

RUN useradd --system --uid 10001 --no-create-home moto
USER 10001

EXPOSE 5000

CMD ["moto_server", "-H", "0.0.0.0"]
