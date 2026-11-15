# Zero trust mapping

The principles below are restated in this project's words from the design of [ChiefGyk3D/Clouds-Against-Humanity](https://github.com/ChiefGyk3D/Clouds-Against-Humanity) (Apache-2.0). That project uses outbound-only connectors, per-resource access and a human confirmation before apply. Each principle is mapped to the control that implements it here. No text was copied.

| Principle | Meaning | Control in this repository | Status |
|-----------|---------|----------------------------|--------|
| Nothing listens inbound by default | No security rule opens a port to the internet unless a reviewed rule says so | Default-deny firewall rules on all three clouds, `no 0.0.0.0/0 on 22 or 3389` policy, AWS security groups with no default ingress or egress, locked default security group | Verified by policy and mock tests |
| Access per resource, not per network | Identities get access to one resource, not to a whole network segment | GitHub OIDC trust bound to repository and ref, GKE workload identity bound to one Kubernetes service account, subnet-level IAM bindings in the Shared VPC | Verified by mock tests |
| No standing credentials | Automation uses short-lived tokens issued at run time | OIDC federation in AWS, Azure and GCP. `no static cloud keys` policy. No access key resources in any module | Verified by policy tests |
| A human confirms every change | Automation proposes, a person applies | Promotion edits the pin and stops. The author commits. Workflows never commit or apply to a real cloud | Verified in `promote.ps1` tests |
| Secrets live in one managed place | One secret store per environment with least-privilege readers | SOPS with age in the repository, Secrets Manager, Key Vault and Secret Manager modules with single-identity access | Verified by tests. Cloud stores Not deployed |
| Public by design | The repository can be public without leaking anything | gitleaks on tree and history, fake demo keys, no account IDs in tracked files | Verified |
| Verify the device and workload | Trust decisions use workload identity and measured state | TPM quote over PCRs with a nonce, PCR-sealed secret, Pod Security restricted | Verified on swtpm and kind. swtpm is not a hardware root of trust |
| Assume breach | Limit blast radius and revoke fast | Intermediate CA with pathlen 0, 90 day leaves, CRL and OCSP, NV counter rollback protection | Verified |

## Gaps

- There is no identity-aware proxy or connector in front of any service. Planned.
- Device posture for human users is not checked. Not covered.
- Network policy enforcement on kind is Not verified.
