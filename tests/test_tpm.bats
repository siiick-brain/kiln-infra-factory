#!/usr/bin/env bats
# TPM 2.0 lifecycle against the swtpm service. swtpm is software and is not a hardware root of trust.
# Run through scripts/test-tpm.ps1, which starts the swtpm container and sets TPM2TOOLS_TCTI.

setup_file() {
  export REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  export TPM_WORK="$(mktemp -d)"
  export PATH="$REPO/tpm/scripts:$PATH"
  export TPM2TOOLS_TCTI="${TPM2TOOLS_TCTI:-swtpm:host=swtpm,port=2321}"
  provision.sh >"$TPM_WORK/provision.log" 2>&1
}

teardown_file() {
  rm -rf "$TPM_WORK"
}

@test "provisioning creates a primary key context" {
  [ -f "$TPM_WORK/primary.ctx" ]
}

@test "a secret sealed to PCR 16 unseals while the PCR is unchanged" {
  printf 'demo-secret-not-real' >"$TPM_WORK/secret.txt"
  run seal.sh "$TPM_WORK/secret.txt"
  [ "$status" -eq 0 ]
  run unseal.sh
  [ "$status" -eq 0 ]
  [ "$output" = "demo-secret-not-real" ]
}

@test "unseal fails after PCR 16 is extended" {
  run extend-pcr.sh 16 "boot-event-changed"
  [ "$status" -eq 0 ]
  run unseal.sh
  [ "$status" -ne 0 ]
}

@test "a quote over PCR 0 and 16 verifies with the attestation key and nonce" {
  run quote.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"QUOTE VERIFIED"* ]]
}

@test "a quote checked with the wrong nonce fails" {
  run quote.sh --wrong-nonce
  [ "$status" -ne 0 ]
}

@test "the NV counter accepts a newer version and refuses a rollback" {
  run nv-counter.sh init
  [ "$status" -eq 0 ]
  run nv-counter.sh accept 1
  [ "$status" -eq 0 ]
  run nv-counter.sh accept 2
  [ "$status" -eq 0 ]
  run nv-counter.sh accept 1
  [ "$status" -ne 0 ]
  [[ "$output" == *"rollback refused"* ]]
}
