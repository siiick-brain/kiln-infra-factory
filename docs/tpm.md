# TPM 2.0 with swtpm

The scripts in `tpm/scripts/` drive tpm2-tools 5.7 against swtpm 0.7.1 running in the `swtpm` Compose service.

**swtpm is a software TPM. It is not a hardware root of trust.** Its state is a file in a Docker volume, so anyone with access to the host can read or reset it. The scripts show the TPM 2.0 commands and the security properties they give on real hardware. They do not give those properties here.

## Connection

The toolbox reaches swtpm over the Compose network with `TPM2TOOLS_TCTI=swtpm:host=swtpm,port=2321`. There is no resource manager, so each script flushes transient objects and sessions on exit.

## Steps

| Step | Script | TPM commands | What it shows |
|------|--------|--------------|---------------|
| Provision | `provision.sh` | `tpm2_startup`, `tpm2_clear -c p`, `tpm2_pcrreset 16` | A known, empty owner hierarchy and a reset debug PCR. |
| Primary key | `create-primary.sh` | `tpm2_createprimary -C o -G ecc256` | A storage key derived from the owner seed. |
| Seal | `seal.sh <file>` | `tpm2_pcrread`, `tpm2_policypcr`, `tpm2_create -L` | A secret bound to the current PCR 16 value. |
| Unseal | `unseal.sh` | `tpm2_load`, `tpm2_unseal -p pcr:sha256:16` | Release only while PCR 16 matches. |
| Extend | `extend-pcr.sh 16 <event>` | `tpm2_pcrextend` | A measured event changes the PCR. Unseal then fails. |
| Quote | `quote.sh` | `tpm2_createek`, `tpm2_createak`, `tpm2_quote`, `tpm2_checkquote` | A signed statement of PCR 0 and 16 bound to a fresh nonce. |
| Rollback protection | `nv-counter.sh init`, `accept <v>` | `tpm2_nvdefine nt=counter`, `tpm2_nvincrement`, `tpm2_nvread` | A monotonic counter refuses an older version. |

PCR 16 is the debug PCR. It is resettable, so the demonstration repeats without restarting swtpm. A real measured boot policy uses PCRs 0 to 7.

The quote check uses the attestation key public part directly. A real verifier also checks that the attestation key belongs to the endorsement key through credential activation and checks the endorsement key certificate. swtpm has no manufacturer certificate, so that step is Not verified.

## Run

```powershell
./scripts/test-tpm.ps1
```

## Evidence

| Check | Result |
|-------|--------|
| `tests/test_tpm.bats` through `scripts/test-tpm.ps1` | 6 of 6 passed on 2026-11-15. Log `artifacts/logs/test-tpm.log`. |

Key handling for the TPM keys is in [key-lifecycle.md](key-lifecycle.md).
