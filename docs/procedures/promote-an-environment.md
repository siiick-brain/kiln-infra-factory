# Promote an environment

Moves a module version pin from one environment to the next after every gate passes.

## Before you start

- The emulator is running: `docker compose up -d emulator`.
- The working tree is clean: `git status` shows nothing to commit.
- You know the source and target environments. The order is dev, stage, prod.

## Steps

1. Run the promotion script.

   ```powershell
   ./scripts/promote.ps1 -From dev -To stage
   ```

2. Read the gate lines. Each gate prints its name and result: fmt, validate, tflint, checkov, conftest, terraform test and emulator plan. Any failure stops the script and leaves the pin unchanged.
3. Review the change: `git diff live/stage/env.hcl`. Only the `module_version` line changes.
4. Run the style check and commit the pin yourself.

   ```powershell
   ./scripts/check-style.ps1 -Staged
   git add live/stage/env.hcl
   git commit -m "chore(promote): stage to <version>"
   ```

5. For prod, repeat with `-From stage -To prod`. The script refuses when stage does not already run the same pin.

## Expected result

The target `env.hcl` holds the new version and the commit records who promoted it and when.

## Roll back

Revert the pin commit and apply. See the [promotion rollback runbook](../runbooks/promotion-rollback.md).
