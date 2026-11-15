# Runbook: drift detected

**Trigger:** the scheduled drift workflow fails. Also when `scripts/drift-check` exits 2.

1. Open the job summary. It lists each unit and the plan diff.
2. Decide whether the change was intended:
   - Unintended: remediate with an apply of the unit from `main`.
     `terragrunt run --all --working-dir live/<env>/aws -- apply`
   - Intended: copy the change into the Terraform code, open a pull request, merge, then apply.
3. Run `scripts/drift-check` again. It must exit 0.
4. Record the unit, the cause and the action in the change log.

**Exit codes:** 0 no drift, 2 drift, any other value a plan error. A plan error is not drift. Fix the error first.

Background: [drift.md](../drift.md).
