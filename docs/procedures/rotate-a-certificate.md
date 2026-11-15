# Rotate a certificate

Replaces a leaf certificate before it expires and deploys it to the nginx host. The old and new certificates overlap.

## Before you start

- The intermediate and public volumes exist (`kiln-pki-intermediate`, `kiln-pki-public`, `kiln-pki-issued`).
- The Rocky target is running and `.env` points at the Ansible key.
- Find certificates inside the warning window:

  ```powershell
  docker compose run --rm -v kiln-pki-intermediate:/pki/intermediate -v kiln-pki-public:/pki/public -v kiln-pki-issued:/pki/issued toolbox pki/scripts/expiry-monitor.sh 30
  ```

## Steps

1. Rotate and deploy. Replace `web` with the certificate name.

   ```powershell
   docker compose run --rm -v kiln-pki-intermediate:/pki/intermediate -v kiln-pki-public:/pki/public -v kiln-pki-issued:/pki/issued toolbox pki/scripts/rotate.sh web --deploy
   ```

2. Read the `ROTATED` line. It prints the old and new serial numbers.
3. Confirm the host serves the new serial:

   ```bash
   echo | openssl s_client -connect rocky-target-1:8443 2>/dev/null | openssl x509 -noout -serial
   ```

4. Wait until every client trusts the new certificate. The previous certificate stays valid in `issued/web/previous/`.
5. Revoke the previous certificate and publish the CRL:

   ```bash
   pki/scripts/revoke.sh /pki/issued/web/previous/cert.pem superseded
   pki/scripts/gen-crl.sh
   ```

## Expected result

The host serves the new serial. nginx reloaded without dropping its master process. `ocsp-check.sh` reports the previous certificate as revoked.

## If it fails

The Ansible run stops before the reload when `nginx -t` fails, so the old certificate keeps serving. Fix the cause and run step 1 again.
