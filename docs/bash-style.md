# Bash style

Rules for every shell script in this repository. They are written for this project. Idnan/bash-guide was read as a general reference only.

## Required

1. Start with `#!/usr/bin/env bash` and a comment that says what the script does.
2. Enable strict mode on the next line: `set -euo pipefail`. A failed command, an unset variable or a failed pipeline stage stops the script.
3. Define `usage()`. It prints to standard error. `-h` and `--help` print it and exit 0. Wrong arguments print it and exit 2.
4. Quote every expansion: `"$var"`, `"${array[@]}"`, `"$(command)"`.
5. Use `[[ ]]` for tests and `(( ))` for arithmetic.
6. Use `local` for function variables.
7. Clean up temporary files with `trap '...' EXIT`.
8. Print one line per check: `PASS name` or `FAIL name: reason`. Print a one-line summary at the end and exit 1 when any check failed.
9. Never print a secret. Write key material only to a temporary directory or a Docker volume.
10. Pass `shellcheck -x` with no findings.

## Patterns

| Need | Pattern |
|------|---------|
| Script directory | `"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` |
| Default value | `"${1:-default}"` |
| Read lines into an array | `mapfile -t items < <(command)` |
| Capture output that may fail | `out="$(command 2>&1 || true)"` |
| Background process under bats | close descriptor 3 with `3>&-` so bats does not wait for it |
| Shared helpers | a `lib.sh` that is sourced with a `# shellcheck source=` directive |

## Avoid

- `eval` and unquoted command substitution.
- Parsing `ls` output.
- `grep -m1` or `head` inside a `pipefail` pipeline when the producer may write more output. The early close fails the pipeline. Capture the output first.
- Windows line endings. `.gitattributes` forces LF so scripts run in Linux containers.

## Enforcement

`tests/test_bash_conventions.bats` checks strict mode, usage text, `--help` and shellcheck for every script under `scripts/`, `pki/`, `tpm/`, `k8s/` and `docker/`. CI runs it on every push.

## Evidence

| Check | Result |
|-------|--------|
| `bats tests/test_bash_conventions.bats` | 5 of 5 passed on 2026-11-15 |
| `shellcheck -x -S style` over all scripts | 0 findings on 2026-11-15. Log `artifacts/logs/shellcheck.log` |
