FROM python:3.15-slim-trixie@sha256:65a65fc7b30b06cb6df4930fd4650697cb23f4c2698ab81fc87e4b031bc36928

COPY docker/emulator/requirements.txt /tmp/requirements.txt
RUN python -m pip install --no-cache-dir -r /tmp/requirements.txt && rm /tmp/requirements.txt

RUN useradd --system --uid 10001 --no-create-home moto
USER 10001

EXPOSE 5000

CMD ["moto_server", "-H", "0.0.0.0"]
