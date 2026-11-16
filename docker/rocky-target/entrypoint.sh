#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${ANSIBLE_AUTHORIZED_KEY:-}" ]]; then
    printf '%s\n' 'ANSIBLE_PUBLIC_KEY is required. Run scripts/new-ansible-key.ps1.' >&2
    exit 2
fi

install -d -o ansible -g ansible -m 0700 /home/ansible/.ssh
printf '%s\n' "$ANSIBLE_AUTHORIZED_KEY" > /home/ansible/.ssh/authorized_keys
chown ansible:ansible /home/ansible/.ssh/authorized_keys
chmod 0600 /home/ansible/.ssh/authorized_keys

ssh-keygen -A
/usr/sbin/sshd -t
exec /usr/sbin/sshd -D -e
