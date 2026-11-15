# Key lifecycle

Procedures for every key class in this repository. Each key class has the same eight sections: generation, storage, use, backup decision, rotation, revocation, destruction and approver.

All keys here are demonstration keys. None protects a real system.

## Key classes

| Key | Algorithm | Where it lives |
|-----|-----------|----------------|
| Root CA key | ECDSA P-384 | `kiln-pki-root` volume, mounted only during a ceremony |
| Intermediate CA key | ECDSA P-384 | `kiln-pki-intermediate` volume |
| Leaf keys | ECDSA P-256 | `kiln-pki-issued` volume and the target host |
| OCSP signing key | ECDSA P-256 | `kiln-pki-issued` volume |
| age key (SOPS) | X25519 | User application data directory outside the repository, GitHub secret `DEMO_AGE_KEY` for CI |
| Ansible SSH key | Ed25519 | Directory set by `ANSIBLE_KEY_DIR`, outside the repository |
| TPM primary and sealed object | ECC P-256 inside swtpm | swtpm state volume. Context files in a temporary directory |
| TPM attestation key | ECDSA P-256 inside swtpm | swtpm state volume |

## Generation

- CA keys are created only by `pki/scripts/ceremony.sh` with `openssl genpkey` under `umask 077`.
- Leaf keys are created by `csr.sh` on the CA host. For a production host the key would be generated on the host and only the CSR would move.
- The age key is created by `scripts/new-age-key.ps1`, which refuses to overwrite an existing key and restricts the file ACL.
- The Ansible key is created by `scripts/new-ansible-key.ps1` outside the repository.
- TPM keys are created inside the TPM and never leave it in plain form.

## Storage

- No private key is committed. `.gitignore` blocks `*.key`, `*.pem` and `.env`. gitleaks runs on the tree and history.
- CA private directories are mode 0700. Key files are mode 0600.
- The root volume is exported to offline media after the ceremony and is not mounted again until the next ceremony.

## Use

| Key | Allowed use |
|-----|-------------|
| Root CA | Sign or revoke an intermediate. Sign the root CRL. |
| Intermediate CA | Sign leaf certificates and the intermediate CRL. |
| OCSP | Sign OCSP responses only (OCSPSigning EKU). |
| Leaf | TLS for the name in its SAN. EKU limits server or client use. |
| age | Decrypt `secrets/*.enc.yaml` in CI and on the workstation. |
| TPM sealed object | Release a secret only while PCR 16 matches. |

## Backup decision

| Key | Backed up | Reason |
|-----|-----------|--------|
| Root CA | Yes, offline media | Losing it forces every relying party to change trust anchors. |
| Intermediate CA | No | A new intermediate can be signed by the root. Fewer copies reduce exposure. |
| Leaf and OCSP | No | Reissue is cheap. |
| age | Yes, one offline copy | Losing it makes committed encrypted files unreadable. |
| Ansible SSH | No | Generate a new pair and redeploy the public key. |
| TPM objects | No | Bound to one TPM by design. Reseal after reprovisioning. |

## Rotation

| Key | Period | Method |
|-----|--------|--------|
| Root CA | 10 years or on compromise | New ceremony, cross-trust period, then reissue. |
| Intermediate CA | 5 years or on compromise | New intermediate from the root, reissue leaves, revoke the old intermediate. |
| Leaf | 90 days, alert at 30 | `rotate.sh <name> --deploy` with overlap. |
| age | Yearly or on exposure | The [age key procedure](procedures/rotate-age-key.md). |
| Ansible SSH | Yearly | New pair, update `.env`, rerun the playbook. |
| TPM sealed object | After any policy change | Reseal with `seal.sh`. |

## Revocation

- Leaf and OCSP certificates: `revoke.sh <name> <reason>`, then `gen-crl.sh`. OCSP reflects the change at the next request.
- Intermediate: revoked by the root during a ceremony. A new root CRL is published.
- age: remove the public key from `.sops.yaml`, run `sops updatekeys` on every file and delete the GitHub secret.
- SSH: remove the public key from the target `authorized_keys`.

## Destruction

- Files: delete the key file and the volume that held it with `docker volume rm`. On SSDs this does not guarantee erasure, so destruction of a real CA key also destroys the media.
- TPM objects: `tpm2_evictcontrol` for persistent handles, `tpm2_clear` for the hierarchy.
- Record the date, the key identifier and the approver in the ceremony log.

## Approver

| Action | Operator | Approver |
|--------|----------|----------|
| Root ceremony, intermediate signing or revocation | Platform engineer | Security lead, present during the ceremony |
| Leaf issue, rotation or revocation | Platform engineer | Peer review of the change |
| age key rotation | Platform engineer | Security lead |
| Key destruction | Platform engineer | Security lead |

In this single-author repository one person holds both roles. That is a stated limitation.
