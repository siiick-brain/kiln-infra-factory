# ADR 0004: Promotion by pinned module versions

## Status

Accepted, 2026-10-30

## Context

Changes must reach prod only after the same code ran in stage. A branch per environment drifts and makes review hard.

## Decision

- Every module has a `VERSION` file. Each environment pins one version in `env.hcl`.
- `scripts/promote.ps1 -From <env> -To <env>` runs the gates (fmt, validate, TFLint, Checkov, Conftest, terraform test, emulator plan) and then edits the pin in the target environment.
- Promotion to prod is refused unless stage already runs the same pin.
- The script never commits. The author reviews the diff and commits by hand. Workflows never commit.

## Consequences

- The Git history of `env.hcl` is the promotion record.
- Rollback is a `git revert` of the pin change followed by an apply.
- A pin that skips stage cannot reach prod through the script.
