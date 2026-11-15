# Environment promotion

Each environment pins the shared module version in `live/<environment>/env.hcl`. `scripts/promote.ps1` runs the gates before changing the target pin. It does not create a commit.

```mermaid
flowchart LR
  dev[dev pin] --> gates[format, validate, TFLint, Checkov, Conftest, Terraform tests]
  gates --> plan[Terragrunt AWS plan against Moto]
  plan --> stage[update target pin]
  stage --> review[review and commit]
  stage --> prod[prod requires stage at the same pin]
```

Run a promotion from dev to stage with:

```powershell
.\scripts\promote.ps1 -From dev -To stage
```

Promotion to prod is blocked unless stage already uses the source version. The script updates only the target `module_version` after each gate succeeds. Azure and GCP units are validated but are not planned against a real cloud.

Rollback by reverting the commit that changed the target pin:

```powershell
git revert <promotion-commit>
```

Promotion unit tests replace Docker with a fake executable. They verify gate ordering, failure handling and the prod pin check. Full gate execution is not verified because the toolbox image build is paused.
