# Linux administration runbook

The Rocky targets accept SSH connections from the local toolbox after `.\scripts\new-ansible-key.ps1` creates an external key pair. The private key ACL allows the current Windows user, local administrators and SYSTEM. Run `.\scripts\test-ansible.ps1` to start both targets, apply the Ansible profile, verify a second run reports `changed=0` and run the testinfra checks.

The target containers do not run systemd. The playbook validates configuration files and the SSH daemon configuration. Run service management exercises on a Rocky Linux virtual machine for host behavior.

## Service inspection

On a Rocky Linux host, use `systemctl status sshd` to inspect the SSH daemon. Use `systemctl restart sshd` after a reviewed configuration change. Read recent service logs with `journalctl -u sshd --since today`.

The target image runs sshd directly as its container process. It does not provide systemctl or a systemd journal.

## Package updates

Use `dnf check-update` to list available packages and `dnf updateinfo list security` to inspect security advisories. Apply reviewed updates with `dnf upgrade`. The Ansible profile configures dnf-automatic for security updates. It does not start a systemd timer in the container.

## Accounts and permissions

Inspect accounts with `getent passwd ansible` and inspect group membership with `id ansible`. Check file owners and modes with `stat -c '%U %G %a %n' /etc/ssh/sshd_config`. Validate sudo rules with `visudo -c`.

The Ansible account has passwordless sudo inside the disposable local targets so the playbook can configure them. Do not copy that container account policy to a shared host without review.

## SELinux

Use `getenforce` and `sestatus` to inspect SELinux on a Rocky host. Use `ls -Z` to inspect labels and `restorecon -Rv /etc/ssh` to restore default labels after an approved file change. The target container cannot validate host SELinux policy or label enforcement.

## Container limits

The Rocky containers do not validate firewalld behavior. On a Rocky virtual machine, use `firewall-cmd --check-config` and inspect active rules with `firewall-cmd --list-all`.

The containers do not run auditd. On a Rocky virtual machine, use `augenrules --check` to validate audit rules and `auditctl -s` to inspect audit status.

The containers do not apply sysctl changes to the host kernel. Review `/etc/sysctl.d/99-kiln-hardening.conf`, then apply and inspect the values on a disposable Rocky virtual machine with `sysctl --system` and `sysctl net.ipv4.conf.all.accept_redirects`.

These checks do not establish CIS compliance.
