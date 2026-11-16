#!/usr/bin/env bash
# Lists issued certificates that expire within N days. Exits 1 when any certificate is inside the window.
set -euo pipefail
# shellcheck source=pki/scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  echo "Usage: expiry-monitor.sh [days]   (default 30)" >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

days="${1:-30}"
seconds=$((days * 86400))
warn=0
for cert in "$PKI_ISSUED_DIR"/*/cert.pem "$PKI_PUBLIC_DIR/intermediate.crt" "$PKI_PUBLIC_DIR/root.crt"; do
  [[ -f "$cert" ]] || continue
  rel="${cert#"$PKI_HOME"/}"
  end="$(openssl x509 -in "$cert" -noout -enddate | cut -d= -f2)"
  if openssl x509 -in "$cert" -noout -checkend "$seconds" >/dev/null; then
    echo "OK   $rel expires $end"
  else
    echo "WARN $rel expires $end"
    warn=$((warn + 1))
  fi
done
echo "Expiry monitor: window $days days, $warn inside window"
((warn == 0))
