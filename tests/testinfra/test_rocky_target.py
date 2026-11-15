def test_target_is_rocky(host):
    assert host.system_info.distribution == "rocky"


def test_ansible_user_has_restricted_sudo(host):
    sudoers = host.file("/etc/sudoers.d/ansible")

    assert sudoers.exists
    assert sudoers.mode == 0o440
    assert "NOPASSWD: ALL" in sudoers.content_string


def test_sshd_rejects_password_and_root_login(host):
    result = host.run("sudo sshd -T -f /etc/ssh/sshd_config")

    assert result.rc == 0
    assert "passwordauthentication no" in result.stdout.lower()
    assert "permitrootlogin no" in result.stdout.lower()
    assert "pubkeyauthentication yes" in result.stdout.lower()


def test_sysctl_baseline_is_configured(host):
    baseline = host.file("/etc/sysctl.d/99-kiln-hardening.conf")

    assert baseline.exists
    assert "net.ipv4.conf.all.accept_redirects = 0" in baseline.content_string
    assert "net.ipv4.conf.all.send_redirects = 0" in baseline.content_string


def test_rsyslog_configuration_is_valid(host):
    assert host.run("sudo rsyslogd -N1").rc == 0
    assert host.file("/etc/rsyslog.d/50-kiln.conf").exists


def test_dnf_automatic_security_updates_are_configured(host):
    config = host.file("/etc/dnf/automatic.conf")

    assert config.exists
    assert "upgrade_type = security" in config.content_string
    assert "apply_updates = yes" in config.content_string


def _effective_commands_section(text):
    """Return the [commands] values as dnf-automatic reads them: the last value of a key wins."""
    values = {}
    counts = {}
    section = None
    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("[") and line.endswith("]"):
            section = line[1:-1]
            continue
        if section == "commands" and "=" in line:
            key, value = (part.strip() for part in line.split("=", 1))
            values[key] = value
            counts[key] = counts.get(key, 0) + 1
    return values, counts


def test_dnf_automatic_effective_values_are_security_only(host):
    values, counts = _effective_commands_section(host.file("/etc/dnf/automatic.conf").content_string)

    assert values.get("upgrade_type") == "security"
    assert values.get("apply_updates") in ("True", "yes", "true")
    assert counts.get("upgrade_type") == 1
    assert counts.get("apply_updates") == 1


def test_sshd_disables_x11_forwarding(host):
    result = host.run("sudo sshd -T -f /etc/ssh/sshd_config")

    assert "x11forwarding no" in result.stdout.lower()
