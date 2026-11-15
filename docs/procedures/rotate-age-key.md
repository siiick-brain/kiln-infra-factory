# Rotate the age key

Replaces the age key that decrypts the SOPS files, then removes the old key.

## Before you start

- The current private key is available so existing files can be decrypted.
- You can edit the GitHub secret `DEMO_AGE_KEY` on the repository page.

## Steps

1. Create a new key outside the repository. The script refuses to overwrite an existing key, so pass a new path:

   ```powershell
   ./scripts/new-age-key.ps1 -KeyPath "$env:APPDATA\sops\age\kiln-infra-factory\keys-2027.txt"
   ```

2. Copy the new public key (`age1...`) from the script output.
3. Add it to `.sops.yaml` next to the old key under `creation_rules`.
4. Re-encrypt every file for both keys:

   ```powershell
   Get-ChildItem secrets -Filter *.enc.yaml | ForEach-Object { sops updatekeys --yes $_.FullName }
   ```

5. Point `SOPS_AGE_KEY_FILE` at the new key and confirm decryption: `sops -d secrets/demo.enc.yaml`.
6. Replace the `DEMO_AGE_KEY` GitHub secret with the new private key.
7. Remove the old public key from `.sops.yaml` and run step 4 again.
8. Run `./tests/test_sops.ps1`. It checks decryption with the key and failure without it.
9. Commit `.sops.yaml` and the re-encrypted files.
10. Destroy the old private key file and record the date in the key log.

## Expected result

Files decrypt with the new key only. CI decrypts with the new secret. The old key cannot decrypt any committed file.
