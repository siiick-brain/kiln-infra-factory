# Drift detection

`scripts/drift-check` runs a detailed Terragrunt plan for the AWS units in dev against the local Moto endpoint. It preserves Terraform's plan diff and exit status:

| Exit code | Meaning |
|---:|---|
| 0 | No drift |
| 2 | Terraform found drift |
| Other | The plan failed |

The local demonstration applies the dev AWS units to Moto, changes an SQS queue attribute through Moto and runs the drift check. Apply the configuration again to restore the declared queue settings:

```powershell
docker compose up -d emulator
.\scripts\tb.ps1 terragrunt run --all --parallelism 1 --non-interactive --working-dir live/dev/aws -- apply -auto-approve -no-color
docker compose exec -T emulator python -c "import boto3; c=boto3.client('sqs', endpoint_url='http://127.0.0.1:5000', region_name='us-east-1', aws_access_key_id='testing', aws_secret_access_key='testing'); u=c.get_queue_url(QueueName='dev-events')['QueueUrl']; c.set_queue_attributes(QueueUrl=u, Attributes={'VisibilityTimeout':'45'})"
bash scripts/drift-check
.\scripts\tb.ps1 terragrunt run --all --parallelism 1 --non-interactive --working-dir live/dev/aws -- apply -auto-approve -no-color
```

The Moto endpoint and credentials in the command are local demo values. This check does not observe real cloud resources. The scheduled workflow provisions the emulator state for its run, checks for drift and never commits changes.

## Observed local run

On 2026-11-01, the baseline apply completed for all four dev AWS units. Setting `dev-events` `VisibilityTimeout` to `45` produced exit code `2`; the plan showed `45 -> 60`. The remediation apply completed for all four units.

A subsequent full drift check did not confirm exit code `0`. It exited `1` because Terraform could not resolve `registry.terraform.io` while initializing `lambda-sqs-consumer`. The SQS plan also continued to report redrive policy and queue policy changes after apply. A clean post-remediation result is **Not verified**. The emulator was local and no cloud account was used.

The scheduled job starts a fresh Moto instance and applies a baseline before checking. It validates the drift command against that run's state but cannot detect changes between scheduled runs.
