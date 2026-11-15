# Runbook: roll back a promotion

**Trigger:** a promoted module version causes a failure in the target environment.

1. Find the pin commit: `git log --oneline -- live/<env>/env.hcl`.
2. Revert it: `git revert <commit>`. The hook checks the commit title and author.
3. Plan the affected units and read the diff: `terragrunt run --all --working-dir live/<env>/aws -- plan`.
4. Apply: `terragrunt run --all --working-dir live/<env>/aws -- apply`.
5. Run `scripts/drift-check`. It must exit 0.
6. If prod was rolled back, also check that stage still runs the version you want to keep. Promotion to prod needs the same pin in stage.

Procedure for forward promotion: [promote an environment](../procedures/promote-an-environment.md).
