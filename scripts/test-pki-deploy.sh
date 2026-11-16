#!/usr/bin/env bash
# End-to-end rotation test: issue a certificate, deploy it to nginx on rocky-target-1 through Ansible,
# rotate it with rotate.sh --deploy and check the served serial changed while the nginx master PID stayed.
# Runs inside the toolbox. Keys live in a temporary directory and are removed on exit.
set -euo pipefail

usage() {
  echo "Usage: bash scripts/test-pki-deploy.sh" >&2
  echo "Needs the Rocky targets running and the Ansible key mounted at /run/ansible-keys." >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi
[[ -f /run/ansible-keys/id_ed25519 ]] || {
  echo "Ansible private key is missing from /run/ansible-keys." >&2
  exit 2
}

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PKI_HOME
PKI_HOME="$(mktemp -d)"
export PATH="$repo/pki/scripts:$PATH"
export ANSIBLE_NOCOLOR=1
install -m 0600 /run/ansible-keys/id_ed25519 /tmp/kiln-ansible-key
trap 'rm -rf "$PKI_HOME"; rm -f /tmp/kiln-ansible-key' EXIT

failed=0
check() {
  if [[ "$2" == "ok" ]]; then echo "PASS $1"; else
    echo "FAIL $1: $2"
    failed=$((failed + 1))
  fi
}

served_serial() {
  echo | openssl s_client -connect rocky-target-1:8443 -servername rocky-target-1 2>/dev/null |
    openssl x509 -noout -serial | cut -d= -f2
}
master_pid() {
  ansible -i "$repo/ansible/inventory.yml" rocky-target-1 -b -m ansible.builtin.command -a 'cat /run/nginx.pid' 2>/dev/null | tail -1
}

ceremony.sh >/dev/null 2>&1
csr.sh web rocky-target-1 "DNS:rocky-target-1" >/dev/null
issue.sh web server_cert >/dev/null
ansible-playbook -i "$repo/ansible/inventory.yml" "$repo/ansible/pki-deploy.yml" \
  -e "cert_deploy_certificate_source=$PKI_HOME/issued/web/fullchain.pem" \
  -e "cert_deploy_private_key_source=$PKI_HOME/issued/web/key.pem" >"$PKI_HOME/deploy-1.log" 2>&1 || {
  tail -20 "$PKI_HOME/deploy-1.log"
  exit 1
}

first_serial="$(served_serial)"
issued_serial="$(openssl x509 -in "$PKI_HOME/issued/web/cert.pem" -noout -serial | cut -d= -f2)"
[[ "$first_serial" == "$issued_serial" ]] && r=ok || r="served $first_serial issued $issued_serial"
check "nginx serves the first certificate" "$r"
pid_before="$(master_pid)"

rotate.sh web --deploy >"$PKI_HOME/rotate.log" 2>&1 || {
  tail -20 "$PKI_HOME/rotate.log"
  exit 1
}
second_serial="$(served_serial)"
new_serial="$(openssl x509 -in "$PKI_HOME/issued/web/cert.pem" -noout -serial | cut -d= -f2)"
pid_after="$(master_pid)"

[[ "$second_serial" == "$new_serial" && "$second_serial" != "$first_serial" ]] && r=ok || r="served $second_serial expected $new_serial"
check "rotation deploys a new serial" "$r"
[[ "$pid_before" =~ ^[0-9]+$ && "$pid_before" == "$pid_after" ]] && r=ok || r="master pid $pid_before then $pid_after"
check "reload is graceful (nginx master PID unchanged)" "$r"
echo | openssl s_client -connect rocky-target-1:8443 -CAfile "$PKI_HOME/public/chain.pem" -verify_return_error >/dev/null 2>&1 && r=ok || r="chain did not verify"
check "served chain verifies against the Kiln root" "$r"
verify.sh "$PKI_HOME/issued/web/previous/cert.pem" >/dev/null && r=ok || r="previous certificate invalid"
check "previous certificate stays valid during overlap" "$r"

echo "PKI deploy: $((5 - failed)) of 5 checks passed. old=$first_serial new=$second_serial"
((failed == 0))
