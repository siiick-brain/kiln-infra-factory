# Respond to CA compromise

Use this when the intermediate CA key may have been copied. For a single leaf key, revoke the leaf with reason `keyCompromise` and rotate it instead.

## Roles

An operator runs the commands. An approver watches the ceremony steps and signs the log.

## Steps

1. Record the time, who reported it and what is known.
2. Stop issuance. Do not run `issue.sh` until step 8.
3. Mount the root volume in a ceremony session:

   ```powershell
   docker compose run --rm -v kiln-pki-root:/pki/root -v kiln-pki-intermediate:/pki/intermediate -v kiln-pki-public:/pki/public toolbox bash
   ```

4. Revoke the intermediate with the root CA:

   ```bash
   source pki/scripts/lib.sh
   openssl ca -config "$ROOT_CNF" -revoke /pki/intermediate/intermediate.crt -crl_reason CACompromise
   openssl ca -config "$ROOT_CNF" -gencrl -out /pki/root/root.crl
   cp /pki/root/root.crl /pki/public/root.crl
   ```

5. Move the old intermediate directory aside for investigation: `mv /pki/intermediate /pki/intermediate-compromised-<date>`.
6. Create a new intermediate key and CSR and sign it with the root. These are steps 3 and 4 of `ceremony.sh`. Run them one at a time and record the new fingerprint.
7. Unmount the root volume and return the media to storage.
8. Reissue every leaf certificate from the new intermediate. The list of names is `ls /pki/intermediate-compromised-<date>/../issued`.
9. Deploy each new certificate with `rotate.sh <name> --deploy`.
10. Publish the new chain and both CRLs. Confirm that a certificate from the old intermediate fails `verify.sh --crl`.

## Expected result

The old intermediate appears on the root CRL. Every host serves a certificate from the new intermediate. The ceremony log holds both fingerprints, the time line and the approver signature.

## If the root key is suspected

Treat every certificate as untrusted. Remove the root from every trust store, run a new ceremony with `ceremony.sh` on new volumes and reissue everything.
