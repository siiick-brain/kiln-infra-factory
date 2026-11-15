# Runbook: Terraform state damaged or lost

**Trigger:** plan shows resources to create that already exist. Also when state pull fails or a lock is stuck.

1. Stop pipelines for the unit.
2. Stuck lock only: confirm no apply is running, then `terragrunt force-unlock <lock-id>`. Stop here if the next plan is clean.
3. Damaged state: save the current object, find the last good version in the versioned bucket and push it back.
4. Plan with `-detailed-exitcode`. The incident ends at exit 0 or at exit 2 with an explained diff.
5. Record the version ID restored and the cause.

Full steps: [recover state](../procedures/recover-state.md). Background: [state.md](../state.md).
