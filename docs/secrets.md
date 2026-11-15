# Secrets management

SOPS encrypts the YAML example with age. The example contains fake values and cannot authenticate to a service.

The private age key stays outside the repository at `%APPDATA%\sops\age\kiln-infra-factory\keys.txt`. Run `.\scripts\new-age-key.ps1` to create a key. The script refuses repository paths and existing key files. Its ACL allows the current Windows user, local administrators and SYSTEM.

Set `SOPS_AGE_KEY_FILE` to the key path before decrypting:

```powershell
$env:SOPS_AGE_KEY_FILE = Join-Path $env:APPDATA 'sops\age\kiln-infra-factory\keys.txt'
.\scripts\tb.ps1 sops --decrypt secrets/demo.enc.yaml
```

Run `.\tests\test_sops.ps1 -SopsPath <path-to-sops.exe>` to check decryption with the key and failure without it. The test only uses the fake example values. The test passed with SOPS 3.13.3 and age 1.3.2 on this Windows host. The toolbox build is not verified.

The CI workflow reads the fake demo identity from the `DEMO_AGE_KEY` GitHub secret. The secret is not configured or verified in this workspace. Configure it only with the private identity for this fake example. Never use a personal or production key.

To rotate the recipient, add the new public recipient to `.sops.yaml`, run `sops updatekeys secrets/demo.enc.yaml`, then verify decryption with the new private key before removing the old recipient. Keep a recovery copy of the key outside the repository and restrict access to it.

Terraform state can contain secret input values even when the source file uses SOPS. Protect state storage and access, avoid exposing values in outputs or logs and follow [state recovery guidance](./state.md).
