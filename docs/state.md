# Terraform state

## Local emulator backend

The `backend/emulator.hcl` settings target Moto on the Compose network. The credentials in this file are fake and must not be changed to cloud credentials. The backend uses the S3-compatible state object with Terraform's native S3 lock file. The state bucket is versioned, encrypted and private. The TLS-only bucket policy is disabled only for this local HTTP emulator.

Start the emulator and run the migration demonstration from the toolbox:

```powershell
docker compose up -d emulator
.\scripts\tb.ps1 bash scripts/migrate-state.sh
```

The script creates a temporary local state, creates a test bucket in Moto, migrates the state to the emulator and reads it back through the S3 backend. It then starts one apply and verifies that a concurrent apply is refused by the state lock. The script removes its temporary files when it exits. No real cloud account is used.

## State contents and access

Terraform state can contain credentials and other sensitive values even when variables are marked sensitive. Do not print state, commit it, upload it to an issue or include it in screenshots. The local demo uses a temporary working directory and fake credentials. For any future remote backend, restrict bucket and object access to the Terraform operators and CI identity that need it. Keep state transport encrypted and retain bucket versions for recovery.

State encryption does not replace access control. A reader of state can recover values that Terraform stores there. Prefer secret references over passing secret values through Terraform and do not output secret values.

## Migration and initialization

When moving an existing local state to a remote backend:

1. Back up the local state in a location with restricted access.
2. Confirm that the backend bucket exists and that the backend endpoint is the intended target.
3. Run `terraform init -migrate-state` and review Terraform's migration prompt.
4. Run `terraform state list` and verify the expected resources.
5. Protect or remove the local state copy according to the recovery plan.

Do not add real credentials to `backend/emulator.hcl`. For another backend, use a separate config file that is ignored by Git and inject credentials through the approved environment or identity provider.

## Recovery

1. Stop other Terraform runs for the workspace and confirm no apply is active.
2. Use the backend's versioning controls to select the last known-good state object version.
3. Store the recovered object in a restricted temporary location and review it before use.
4. Run `terraform state push <recovered-state-file>` only after confirming the destination workspace and state lineage.
5. Run `terraform state list` and a fresh plan to compare state with the intended configuration.

Do not use `terraform force-unlock` to remove a lock while another operation may still be running. Use it only after confirming that the lock belongs to a failed operation and record the lock ID and reason.

## Terraform state commands

Run these commands from the initialized working directory. Commands that read state can expose sensitive values.

| Command | Use |
|---|---|
| `terraform state list` | List resource addresses in the current state. |
| `terraform state show <address>` | Inspect one resource in state. |
| `terraform state pull` | Read the current state as JSON. Protect its output. |
| `terraform state mv <source> <destination>` | Move a resource address after a configuration refactor. |
| `terraform state rm <address>` | Stop tracking an address without destroying the remote object. |
| `terraform import <address> <id>` | Add an existing object to state after confirming its configuration. |
| `terraform force-unlock <lock-id>` | Remove a stale lock only after confirming no operation is active. |

`terraform state rm`, `terraform state push` and `terraform force-unlock` can disrupt later Terraform operations. Review the target workspace and keep a protected backup before using them.

## Verification

The emulator migration and lock demonstration are not verified until `scripts/migrate-state.sh` has completed successfully. No real backend migration, account access or recovery exercise has been performed.
