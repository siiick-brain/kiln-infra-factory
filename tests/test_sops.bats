#!/usr/bin/env bats
# SOPS with age: decryption works with the key and fails without it.
# The private key is mounted read-only from outside the repository at /run/age/keys.txt.
# Run: docker compose run --rm --no-deps -v "<key-dir>:/run/age:ro" toolbox bats tests/test_sops.bats

setup() {
  FILE="$BATS_TEST_DIRNAME/../secrets/demo.enc.yaml"
  KEY="${SOPS_KEY_FILE:-/run/age/keys.txt}"
}

@test "the committed file does not contain the plaintext username" {
  run grep -c 'demo-user' "$FILE"
  [ "$output" = "0" ]
}

@test "decryption with the age key returns the fake values" {
  [ -f "$KEY" ] || skip "no key mounted"
  run env SOPS_AGE_KEY_FILE="$KEY" sops -d "$FILE"
  [ "$status" -eq 0 ]
  [[ "$output" == *"username: demo-user"* ]]
}

@test "decryption without a key fails" {
  run env -u SOPS_AGE_KEY -u SOPS_AGE_KEY_FILE HOME="$BATS_TEST_TMPDIR" sops -d "$FILE"
  [ "$status" -ne 0 ]
}
