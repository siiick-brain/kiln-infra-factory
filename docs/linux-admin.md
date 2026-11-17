# Linux administration

Exercises against the Rocky Linux target. The outputs were captured on Rocky Linux 9.8. The target now runs 10.2. The topic order follows the outline of [linuxupskillchallenge](https://github.com/livialima/linuxupskillchallenge) (CC-BY-4.0). The exercises and notes are this project's own.

Run every exercise and save the output:

```bash
docker compose up -d rocky-target-1
bash scripts/linux-exercises.sh
```

Each file in [outputs/](linux-admin/outputs/) holds the command and its real output with the run date.

## Limits of the container

The target runs `sshd` as process 1. There is no systemd, journal, cron daemon, firewalld or auditd. Exercises that need them show what the container has instead and state the gap. Use a Rocky virtual machine for service management, timers and kernel settings. [ansible.md](ansible.md) lists how each gap is checked.

## Topics

| Day | Topic | Exercise | Output |
|-----|-------|----------|--------|
| 1 | Get to know the server | Kernel, OS release, CPUs, memory and root filesystem | [01-server](linux-admin/outputs/01-server.txt) |
| 2 | Navigation | Move into `/etc/ssh` and list it with permissions | [02-navigation](linux-admin/outputs/02-navigation.txt) |
| 3 | Privilege | `id` and the sudo rules of the `ansible` user | [03-privilege](linux-admin/outputs/03-privilege.txt) |
| 4 | Installing software | Query installed packages with `rpm -q` | [04-software](linux-admin/outputs/04-software.txt) |
| 5 | Reading files | Count and preview `/etc/passwd` | [05-paging](linux-admin/outputs/05-paging.txt) |
| 6 | Editing | Check which editors exist and read the SSH drop-in | [06-editing](linux-admin/outputs/06-editing.txt) |
| 7 | Services | Process list and effective SSH settings with `sshd -T` | [07-services](linux-admin/outputs/07-services.txt) |
| 8 | grep and text tools | Find SSH settings with `grep`, list login shells with `awk` | [08-text](linux-admin/outputs/08-text.txt) |
| 9 | Networking | Resolve the second target, read listening sockets from `/proc/net/tcp` | [09-networking](linux-admin/outputs/09-networking.txt) |
| 10 | Scheduling | Look for cron directories, read the dnf-automatic settings | [10-scheduling](linux-admin/outputs/10-scheduling.txt) |
| 11 | Finding things | Recently changed config files and setuid binaries with `find` | [11-finding](linux-admin/outputs/11-finding.txt) |
| 12 | Transferring files | Copy a file and compare SHA-256 sums | [12-transfer](linux-admin/outputs/12-transfer.txt) |
| 13 | Users and groups | `getent` and `id` for the automation user | [13-users](linux-admin/outputs/13-users.txt) |
| 14 | Permissions | Modes and owners of SSH, shadow, sudoers and TLS key paths | [14-permissions](linux-admin/outputs/14-permissions.txt) |
| 15 | Repositories | List configured repositories and count packages | [15-repositories](linux-admin/outputs/15-repositories.txt) |
| 16 | Archives | Create and list a compressed tar of the SSH drop-ins | [16-archives](linux-admin/outputs/16-archives.txt) |
| 17 | Building from source | Check for a compiler | [17-build](linux-admin/outputs/17-build.txt) |
| 18 | Logs and troubleshooting | Validate rsyslog configuration and list log files | [18-logs](linux-admin/outputs/18-logs.txt) |
| 19 | Inodes and links | Show an inode number, create a symbolic link, check inode use | [19-inodes](linux-admin/outputs/19-inodes.txt) |
| 20 | Scripting | A loop that reports whether each managed file is present | [20-scripting](linux-admin/outputs/20-scripting.txt) |

## Findings from the exercises

The first run on 2026-11-15 found two problems in the Ansible roles. Both were fixed with a failing test first.

| Exercise | Finding | Fix |
|----------|---------|-----|
| 7 | `sshd -T` reported `x11forwarding yes` | `ssh_hardening` sets `X11Forwarding no`. testinfra checks the effective value |
| 10 | `/etc/dnf/automatic.conf` held `upgrade_type` and `apply_updates` twice in `[commands]`. dnf-automatic reads the last value, so the defaults (`default`, `no`) were in effect | `updates` replaces each key in place with `lineinfile`. testinfra parses the section and checks each key appears once |

Day 17 is Not verified: the target image has no compiler, by design.
