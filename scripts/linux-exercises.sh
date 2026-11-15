#!/usr/bin/env bash
# Runs one Linux administration exercise per topic against rocky-target-1 and saves each command
# with its output under docs/linux-admin/outputs/. Topics follow the linuxupskillchallenge outline.
# Runs on the host with Docker Compose. The target must be running.
set -euo pipefail

usage() {
  echo "Usage: scripts/linux-exercises.sh" >&2
  echo "Start the target first: docker compose up -d rocky-target-1" >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="$repo/docs/linux-admin/outputs"
mkdir -p "$out"
cd "$repo"

run() {
  local file="$1"
  local cmd="$2"
  {
    echo "# Target: rocky-target-1. Date: $(date -u +%Y-%m-%d)"
    echo "\$ $cmd"
    docker compose exec -T rocky-target-1 bash -c "$cmd" 2>&1 || echo "(exit $?)"
  } >"$out/$file.txt"
  echo "SAVED $file"
}

run 01-server "uname -sr; grep -E '^(NAME|VERSION)=' /etc/os-release; nproc; free -m | head -2; df -h / | tail -1"
run 02-navigation "cd /etc/ssh && pwd && ls -la | head -8"
run 03-privilege "id ansible; sudo -l -U ansible | tail -3"
run 04-software "rpm -q openssh-server nginx rsyslog dnf-automatic; ls / | tr '\n' ' '"
run 05-paging "wc -l /etc/passwd; head -3 /etc/passwd"
run 06-editing "command -v vi vim nano || echo 'no interactive editor installed'; sed -n '1,6p' /etc/ssh/sshd_config.d/*.conf"
run 07-services "ps -eo pid,user,comm | head -8; sshd -T | grep -E '^(permitrootlogin|passwordauthentication|x11forwarding) '"
run 08-text "grep -rhE '^(PermitRootLogin|PasswordAuthentication)' /etc/ssh/sshd_config.d/; awk -F: '\$7 !~ /nologin|false/ {print \$1, \$7}' /etc/passwd"
run 09-networking "getent hosts rocky-target-2; awk 'NR>1 {print \$2}' /proc/net/tcp | head -5; cat /etc/resolv.conf | grep -v '^#' | head -3"
run 10-scheduling "ls /etc/cron.d /etc/cron.daily 2>&1 | head -6; grep -E '^(upgrade_type|apply_updates) ' /etc/dnf/automatic.conf"
run 11-finding "find /etc/ssh /etc/sudoers.d -type f -newer /etc/os-release | head -5; find /usr/bin /usr/sbin -perm -4000 -type f | head -6"
run 12-transfer "cp /etc/hostname /tmp/hostname.copy && sha256sum /etc/hostname /tmp/hostname.copy"
run 13-users "getent passwd ansible; id ansible; getent group wheel"
run 14-permissions "stat -c '%a %U %G %n' /etc/ssh/sshd_config /etc/shadow /etc/sudoers.d/* /etc/pki/tls/private 2>&1"
run 15-repositories "ls /etc/yum.repos.d; rpm -qa | wc -l"
run 16-archives "tar czf /tmp/ssh-config.tgz -C /etc ssh/sshd_config.d && tar tzvf /tmp/ssh-config.tgz"
run 17-build "command -v gcc make || echo 'gcc and make are not installed in the target image'"
run 18-logs "rsyslogd -N1 2>&1 | tail -2; ls /etc/rsyslog.d; ls /var/log | head -8"
run 19-inodes "ls -li /etc/hostname; ln -sf /etc/hostname /tmp/hostname.link && ls -l /tmp/hostname.link; df -i / | tail -1"
run 20-scripting "for f in /etc/ssh/sshd_config /etc/dnf/automatic.conf /etc/sysctl.d/99-kiln-hardening.conf; do if [[ -f \$f ]]; then echo \"present \$f\"; else echo \"missing \$f\"; fi; done"

echo "Linux exercises: 20 outputs in docs/linux-admin/outputs/"
