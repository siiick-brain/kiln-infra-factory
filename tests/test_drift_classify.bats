#!/usr/bin/env bats
# drift-classify.sh ignores only the Moto policy JSON whitespace artifact. Every other change is drift.

setup() {
  CLASSIFY="$BATS_TEST_DIRNAME/../scripts/drift-classify.sh"
  FIX="$BATS_TEST_DIRNAME/fixtures/drift"
}

@test "the SQS whitespace artifact alone is not drift" {
  run bash "$CLASSIFY" "$FIX/artifact-only.log"
  [ "$status" -eq 0 ]
}

@test "a bucket policy change is drift" {
  run bash "$CLASSIFY" "$FIX/bucket-policy.log"
  [ "$status" -eq 2 ]
  [[ "$output" == *"policy"* ]]
}

@test "a redrive policy change without the whitespace marker is drift" {
  run bash "$CLASSIFY" "$FIX/redrive-real.log"
  [ "$status" -eq 2 ]
}

@test "a visibility timeout change is drift" {
  run bash "$CLASSIFY" "$FIX/visibility.log"
  [ "$status" -eq 2 ]
  [[ "$output" == *"visibility_timeout_seconds"* ]]
}
