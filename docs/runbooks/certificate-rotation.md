# Runbook: certificate near expiry

**Trigger:** `pki/scripts/expiry-monitor.sh 30` exits 1. Also when a client reports an expired certificate.

1. List what is inside the window: `pki/scripts/expiry-monitor.sh 30`.
2. For each leaf, rotate and deploy: `pki/scripts/rotate.sh <name> --deploy`.
3. Confirm the served serial changed: `echo | openssl s_client -connect <host>:8443 | openssl x509 -noout -serial`.
4. After all clients use the new certificate, revoke the previous one with reason `superseded` and run `gen-crl.sh`.
5. If the intermediate itself is inside the window, a root ceremony is needed. Schedule it with the approver.

Full steps: [rotate a certificate](../procedures/rotate-a-certificate.md).
