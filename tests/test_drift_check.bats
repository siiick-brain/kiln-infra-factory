setup() {
  export DRIFT_TEST_LOG="$BATS_TEST_TMPDIR/terragrunt.log"
  export DRIFT_TEST_EXIT=0
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  cat >"$BATS_TEST_TMPDIR/bin/terragrunt" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$DRIFT_TEST_LOG"
printf 'fixture plan output\n'
exit "$DRIFT_TEST_EXIT"
STUB
  chmod +x "$BATS_TEST_TMPDIR/bin/terragrunt"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
}

@test "help prints usage" {
  run bash "$BATS_TEST_DIRNAME/../scripts/drift-check" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "rejects unsupported arguments" {
  run bash "$BATS_TEST_DIRNAME/../scripts/drift-check" unexpected
  [ "$status" -eq 2 ]
  [[ "$output" == *"Usage:"* ]]
  [ ! -e "$DRIFT_TEST_LOG" ]
}

@test "runs a detailed plan for dev AWS units" {
  run bash "$BATS_TEST_DIRNAME/../scripts/drift-check"
  [ "$status" -eq 0 ]
  [[ "$output" == *"fixture plan output"* ]]
  grep -q -- "-- plan -detailed-exitcode -no-color" "$DRIFT_TEST_LOG"
}

@test "returns drift status and preserves the plan diff" {
  export DRIFT_TEST_EXIT=2
  run bash "$BATS_TEST_DIRNAME/../scripts/drift-check"
  [ "$status" -eq 2 ]
  [[ "$output" == *"fixture plan output"* ]]
  [[ "$output" == *"Drift detected"* ]]
}

@test "returns plan errors without reporting drift" {
  export DRIFT_TEST_EXIT=1
  run bash "$BATS_TEST_DIRNAME/../scripts/drift-check"
  [ "$status" -eq 1 ]
  [[ "$output" == *"fixture plan output"* ]]
  [[ "$output" != *"Drift detected"* ]]
}
