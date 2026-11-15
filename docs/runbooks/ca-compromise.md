# Runbook: CA key compromise

**Trigger:** evidence that the intermediate or root private key was copied. Also when certificates appear that no operator issued.

1. Declare an incident. Name the operator and the approver.
2. Stop all issuance.
3. Collect `index.txt` from the intermediate volume. Compare it with the expected issuance list.
4. Follow [respond to CA compromise](../procedures/respond-to-ca-compromise.md): revoke the intermediate with the root, publish the root CRL, create a new intermediate, reissue and deploy every leaf.
5. Confirm a certificate from the old intermediate fails `verify.sh --crl`.
6. Write the incident record: time line, fingerprints of old and new intermediates, list of reissued certificates.

If the root key is suspected, every certificate is untrusted. Run a new ceremony.
