# Drift detection

`scripts/drift-check` runs `terraform plan -detailed-exitcode` through Terragrunt for the dev AWS units against the Moto emulator. It keeps Terraform's plan diff and exit status.

| Exit code | Meaning |
|---:|---|
| 0 | No drift |
| 2 | Terraform found a difference |
| Other | The plan failed. A plan error is not drift |

## Demonstration

`scripts/drift-demo.sh` runs inside the toolbox with the emulator up:

1. Create the versioned state bucket on the emulator (`scripts/bootstrap-state-bucket.sh`).
2. Apply the four dev AWS units.
3. Set the `dev-events` queue visibility timeout to 45 seconds with a direct SQS API call. This is the out-of-band change.
4. Run the drift check. Expect exit 2 and `visibility_timeout_seconds 45 -> 60` in the diff.
5. Apply again to remediate.
6. Run the drift check again.

```powershell
docker compose up -d emulator
docker compose run --rm --no-deps toolbox bash scripts/drift-demo.sh
```

The endpoint and the `testing` credentials are local emulator values. No cloud account is involved.

## The emulator artifacts

Moto returns queue policy JSON with a space after each separator. AWS returns it compact. The AWS provider therefore reports a whitespace-only change on `redrive_policy` and recomputes the dependent queue policy on every plan. Exit code 0 is never reached on the emulator, even with no real change.

AWS provider 6.x sends bucket tags inside the `CreateBucket` request. Moto 5.2.5 reads only `LocationConstraint` from that request and drops the tags, so `GetBucketTagging` returns `NoSuchTagSet` and the first plan after a fresh apply adds every tag back. The next apply sets them with `PutBucketTagging`, which Moto stores.

`scripts/drift-classify.sh` separates those artifacts from real drift. It ignores exactly these:

- `redrive_policy` on `aws_sqs_queue` when Terraform marks the line `# whitespace changes`
- `policy` on `aws_sqs_queue_policy`
- `tags` and `tags_all` on `aws_s3_bucket` when every entry in the diff is an addition. A changed or removed tag is drift

Every other changed attribute counts as drift, including a `policy` on a bucket or an IAM role. `tests/test_drift_classify.bats` proves both sides. Use the classifier only against emulator plans. Against real AWS every change is drift.

## Results on 2026-11-15

Log: `artifacts/logs/drift-demo.log` and the step logs in `artifacts/logs/drift-demo/`.

| Step | Result |
|------|--------|
| Baseline apply | PASS |
| Check after apply | exit 2. Besides the whitespace artifact, the state bucket showed a `tags` change that disappeared after the next apply. Explained on 2026-11-17: Moto drops tags sent in `CreateBucket` (see above) |
| Out-of-band change | PASS |
| Check after the change | PASS: exit 2 with `visibility_timeout_seconds 45 -> 60` |
| Remediation apply | PASS |
| Check after remediation | exit 2 from the artifact only. The classifier reports no other changed attribute. The injected change is gone |

Status: drift detection with exit code 2 is Verified on the emulator. A clean exit 0 after remediation is **Not verified** because of the artifact above.

## Scheduled workflow

`.github/workflows/drift.yml` runs weekly and on demand. It starts a fresh emulator, applies the dev baseline, runs the drift check and writes the exit code to the job summary. On exit 2 it runs the classifier and fails only when a real attribute changed. It never commits and never opens issues. A fresh emulator holds no state between runs, so the job checks the drift tooling rather than long-lived infrastructure.

Runbook: [drift detected](runbooks/drift.md).
