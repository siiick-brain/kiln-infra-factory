# Ansible and Rocky Linux

`ansible/site.yml` configures two Rocky Linux 9.8 containers built from `docker/rocky-target`. Each container runs `sshd` as its main process and has a non-root `ansible` user. The SSH key pair is created at run time by `scripts/new-ansible-key.ps1` outside the repository.

## Roles

| Role | What it configures | How it is checked |
|------|--------------------|-------------------|
| base | Required packages and directories | testinfra: target reports Rocky Linux |
| users_sudo | `ansible` user and a restricted sudoers file validated with `visudo` | testinfra: sudo rule content and mode |
| ssh_hardening | `sshd_config` drop-in: no root login and no password authentication. Reload with `pkill -HUP sshd` | testinfra: `sshd -T` output |
| sysctl_hardening | `/etc/sysctl.d/99-kiln-hardening.conf` | testinfra: file content. Values are not applied in the container |
| logging | rsyslog drop-in validated with `rsyslogd -N1` | testinfra: configuration check passes |
| cert_deploy | TLS certificate and key, optional nginx server block with graceful reload | `scripts/test-pki-deploy.sh` |
| updates | `dnf-automatic` set to security updates | testinfra: `automatic.conf` values |

## Run

```powershell
./scripts/new-ansible-key.ps1
./scripts/test-ansible.ps1
```

The test runs ansible-lint, applies the playbook twice and fails if the second run reports any change. It then runs the testinfra checks.

## What the containers cannot test

| Control | Why the container cannot test it | How it is checked instead |
|---------|----------------------------------|---------------------------|
| firewalld | No systemd and no netfilter access without extra privileges | Not covered by a role. Planned for a Rocky virtual machine. Network rules are checked in the cloud modules and policies. |
| auditd | The kernel audit subsystem belongs to the host kernel | Not covered by a role. Planned for a Rocky virtual machine. |
| Kernel parameters | `sysctl -w` would change the shared Docker host kernel | The role writes the file. testinfra checks the file content. Applying the values is Not verified. |
| systemd timers and services | The container has no systemd | `dnf-automatic` configuration is checked. The timer is Not verified. |
| SELinux enforcing mode | Containers share the host SELinux state | Not verified. |

## Evidence

| Check | Command | Result |
|-------|---------|--------|
| ansible-lint | inside `scripts/test-ansible.ps1` | 0 failures, 0 warnings in 10 files. Profile `production` met on 2026-11-15. |
| Idempotence | inside `scripts/test-ansible.ps1` | First run changed=5 per target. Second run changed=0 on both targets on 2026-11-15. |
| testinfra | inside `scripts/test-ansible.ps1` | 12 passed (6 tests on each of 2 targets) on 2026-11-15. Log `artifacts/logs/test-ansible.log`. |

This profile is informed by common Linux hardening guidance. It is not a CIS benchmark implementation and makes no compliance claim.
