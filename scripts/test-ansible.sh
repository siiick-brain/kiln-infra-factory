#!/usr/bin/env bash
set -euo pipefail

usage() {
    printf '%s\n' 'Usage: bash scripts/test-ansible.sh'
    printf '%s\n' 'Run lint, provision both Rocky targets and verify idempotence and host state.'
}

if [[ "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if [[ "$#" -ne 0 ]]; then
    usage >&2
    exit 2
fi

if [[ ! -f /run/ansible-keys/id_ed25519 ]]; then
    printf '%s\n' 'Ansible private key is missing from /run/ansible-keys.' >&2
    exit 2
fi

install -m 0600 /run/ansible-keys/id_ed25519 /tmp/kiln-ansible-key
output_directory="$(mktemp -d)"
trap 'rm -rf "$output_directory"; rm -f /tmp/kiln-ansible-key' EXIT
export ANSIBLE_NOCOLOR=1

ansible-lint ansible/site.yml
ansible-playbook --inventory ansible/inventory.yml ansible/site.yml >"$output_directory/first-run.txt" 2>&1 || {
    cat "$output_directory/first-run.txt"
    exit 1
}
cat "$output_directory/first-run.txt"

ansible-playbook --inventory ansible/inventory.yml ansible/site.yml >"$output_directory/second-run.txt" 2>&1 || {
    cat "$output_directory/second-run.txt"
    exit 1
}
cat "$output_directory/second-run.txt"

first_recap="$(grep -E '^rocky-target-[12][[:space:]]+:' "$output_directory/first-run.txt")"
second_recap="$(grep -E '^rocky-target-[12][[:space:]]+:' "$output_directory/second-run.txt")"
if [[ "$(printf '%s\n' "$first_recap" | wc -l)" -ne 2 ||
    "$(printf '%s\n' "$second_recap" | wc -l)" -ne 2 ]]; then
    printf '%s\n' 'Could not find both target recap lines.' >&2
    exit 1
fi

first_changes="$(printf '%s\n' "$first_recap" | grep -Eo 'changed=[0-9]+' | awk -F= '{total += $2} END {print total + 0}')"
if [[ "$first_changes" -eq 0 ]]; then
    printf '%s\n' 'The first playbook run changed no target state.' >&2
    exit 1
fi

if printf '%s\n' "$second_recap" | grep -Eq 'changed=[1-9]|failed=[1-9]|unreachable=[1-9]'; then
    printf '%s\n' 'The second playbook run was not idempotent.' >&2
    exit 1
fi

pytest --hosts=ansible://all tests/testinfra
