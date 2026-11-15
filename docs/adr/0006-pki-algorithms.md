# ADR 0006: PKI algorithm choices

## Status

Accepted, 2026-11-15

## Context

The PKI needs a root, an intermediate, TLS leaves, an OCSP signer and Kubernetes component certificates. OpenSSL 3.5 in the toolbox is the only tool.

## Decision

| Item | Choice | Reason |
|------|--------|--------|
| CA keys | ECDSA P-384 | Long-lived keys get the larger curve. Broad support in OpenSSL, Go and browsers. |
| Leaf and OCSP keys | ECDSA P-256 | Short-lived. Fastest and most widely supported curve for TLS. |
| Signature digest | SHA-384 for CA signatures | Matches the P-384 security level. |
| Root validity | 10 years | Long enough for a demonstration trust anchor. |
| Intermediate validity | 5 years, pathlen 0 | Limits damage. It cannot create further CAs. |
| Leaf validity | 90 days | Forces automated rotation. Kubernetes component certificates use 365 days. |
| Revocation | CRL plus OCSP | CRL for offline checks, OCSP for current status. |
| Service account signing | ECDSA P-256 key pair | Supported by the Kubernetes API server for token signing. |

RSA is not used. Post-quantum algorithms are Planned for review once client support for ML-DSA certificates is common.

## Consequences

- Very old clients without ECDSA support cannot use these certificates.
- The OpenSSL OCSP responder is single-threaded, which is acceptable for the demonstration only.
