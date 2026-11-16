#!/usr/bin/env bash
# Starts or stops an OpenSSL OCSP responder that answers from the intermediate CA index.
set -euo pipefail
# shellcheck source=pki/scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  echo "Usage: ocsp-responder.sh start|stop|foreground [port]" >&2
  echo "foreground runs in the current process and is used by the ocsp container." >&2
}

action="${1:-}"
port="${2:-${OCSP_PORT:-2560}}"
pidfile="$PKI_HOME/ocsp.pid"
cmd=(openssl ocsp -index "${OCSP_INDEX:-$PKI_PUBLIC_DIR/index.txt}" -port "$port"
  -rsigner "$PKI_ISSUED_DIR/ocsp/cert.pem" -rkey "$PKI_ISSUED_DIR/ocsp/key.pem"
  -CA "$PKI_PUBLIC_DIR/intermediate.crt" -nmin 5 -timeout 5)

case "$action" in
  start)
    "${cmd[@]}" >"$PKI_HOME/ocsp.log" 2>&1 3>&- &
    echo $! >"$pidfile"
    # Wait for the log line. A TCP probe would occupy the single-threaded responder.
    for _ in $(seq 1 25); do
      if grep -q 'waiting for OCSP client connections' "$PKI_HOME/ocsp.log" 2>/dev/null; then
        echo "OCSP responder on port $port"
        exit 0
      fi
      sleep 0.2
    done
    die "OCSP responder did not start"
    ;;
  stop)
    if [[ -f "$pidfile" ]]; then
      kill "$(cat "$pidfile")" 2>/dev/null || true
      rm -f "$pidfile"
    fi
    ;;
  foreground)
    exec "${cmd[@]}"
    ;;
  -h | --help)
    usage
    ;;
  *)
    usage
    exit 2
    ;;
esac
