# ADR 0002: SOPS with age

## Status

Accepted

## Decision

Encrypt the repository's YAML secret example with SOPS and age. Keep private age identities outside the repository. Use a fake demo identity in CI.

## Consequences

Encrypted examples can be reviewed without committing plaintext. Decryption requires an age private key. Terraform state can still contain secret values and needs separate access controls.
