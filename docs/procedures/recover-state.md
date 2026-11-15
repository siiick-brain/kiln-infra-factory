# Recover Terraform state

Restores a damaged or lost state object from the versioned state bucket.

## Before you start

- Stop every pipeline that could apply to the affected unit.
- Identify the unit, for example `live/dev/aws/sqs`.
- Never edit state JSON by hand without a backup.

## Steps

1. Save the current state, even if it looks wrong:

   ```bash
   cd live/dev/aws/sqs
   terragrunt state pull > /tmp/state-before-recovery.json
   ```

2. List earlier versions of the state object. The AWS CLI is not in the toolbox, so run these from a host that has it. On the emulator:

   ```bash
   aws --endpoint-url http://127.0.0.1:5000 s3api list-object-versions --bucket <state-bucket> --prefix dev/aws/sqs/
   ```

   On a real account use the same command without `--endpoint-url`.
3. Download the last good version:

   ```bash
   aws s3api get-object --bucket <state-bucket> --key dev/aws/sqs/terraform.tfstate --version-id <id> /tmp/state-good.json
   ```

4. Check that the serial and lineage make sense: `jq '.serial, .lineage' /tmp/state-good.json`.
5. Push it back. `-force` is needed only when the serial is lower than the current one.

   ```bash
   terragrunt state push /tmp/state-good.json
   ```

6. If a stale lock remains, release it with the lock ID from the error message: `terragrunt force-unlock <lock-id>`.
7. Run a plan. Expect no changes or only changes that match real drift:

   ```bash
   terragrunt plan -detailed-exitcode
   ```

## Expected result

The plan exits 0 or exits 2 with a diff you can explain. Record the recovered version ID and the reason in the change log.

Background on state commands and secrets in state: [state.md](../state.md).
