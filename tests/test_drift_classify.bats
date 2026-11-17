#!/usr/bin/env bats
# drift-classify.sh ignores only the Moto policy JSON whitespace artifact. Every other change is drift.

setup() {
  CLASSIFY="$BATS_TEST_DIRNAME/../scripts/drift-classify.sh"
  FIX="$BATS_TEST_DIRNAME/fixtures/drift"
}

@test "every drift fixture is present" {
  for name in artifact-only bucket-policy redrive-real visibility bucket-tags-added bucket-tags-changed bucket-tags-removed; do
    [ -f "$FIX/$name.log" ]
  done
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

@test "bucket tags that Moto dropped on create are not drift" {
  run bash "$CLASSIFY" "$FIX/bucket-tags-added.log"
  [ "$status" -eq 0 ]
}

@test "a changed bucket tag value is drift" {
  run bash "$CLASSIFY" "$FIX/bucket-tags-changed.log"
  [ "$status" -eq 2 ]
  [[ "$output" == *"tags"* ]]
}

@test "a removed bucket tag is drift" {
  run bash "$CLASSIFY" "$FIX/bucket-tags-removed.log"
  [ "$status" -eq 2 ]
  [[ "$output" == *"tags"* ]]
}
