# Contributing

This is a single-author portfolio repository. Issues that report a bug or a documentation error are welcome.

## Before you open a pull request

1. Read [docs/STYLE.md](docs/STYLE.md).
2. Run `./scripts/check-style.ps1` and fix every FAIL.
3. Run the tests for the area you changed. The [documentation index](docs/README.md) lists the commands per area.
4. Use a Conventional Commit title, for example `fix(policy): deny port ranges that include 22`.

## Rules

- Do not add credentials, real account IDs or real certificates.
- Do not weaken a test to make it pass. Fix the code and add a regression test.
- Pin every image and GitHub Action.
