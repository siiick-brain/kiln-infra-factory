#!/usr/bin/env bats
# Every shell script uses strict mode, has usage text and answers --help without side effects.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  mapfile -t SCRIPTS < <(cd "$REPO" && find scripts pki tpm k8s docker -type f \( -name '*.sh' -o -name 'drift-check' -o -name 'commit-msg' \) | sort)
}

@test "at least 25 shell scripts are covered" {
  [ "${#SCRIPTS[@]}" -ge 25 ]
}

@test "every script enables set -euo pipefail" {
  for s in "${SCRIPTS[@]}"; do
    grep -q '^set -euo pipefail' "$REPO/$s" || { echo "missing strict mode: $s"; return 1; }
  done
}

@test "every script has a usage function" {
  for s in "${SCRIPTS[@]}"; do
    case "$s" in */lib.sh | docker/rocky-target/entrypoint.sh) continue ;; esac
    grep -q '^usage()' "$REPO/$s" || { echo "missing usage: $s"; return 1; }
  done
}

@test "every script with a usage function exits 0 on --help" {
  for s in "${SCRIPTS[@]}"; do
    case "$s" in */lib.sh | docker/rocky-target/entrypoint.sh | scripts/hooks/commit-msg) continue ;; esac
    run env PKI_HOME="$BATS_TEST_TMPDIR/pki" TPM_WORK="$BATS_TEST_TMPDIR/tpm" bash "$REPO/$s" --help
    [ "$status" -eq 0 ] || { echo "--help failed ($status): $s"; return 1; }
  done
}

@test "every script passes shellcheck" {
  cd "$REPO"
  run shellcheck -x "${SCRIPTS[@]}"
  [ "$status" -eq 0 ] || { echo "$output" | head -20; return 1; }
}
