#!/usr/bin/env bash
# Rollback protection with a monotonic NV counter.
# A TPM counter starts at an implementation-chosen value, so init records that baseline.
# Version v maps to counter value baseline + v. accept refuses any version whose target is
# below the current counter, then increments the counter up to the target. It never moves back.
set -euo pipefail
# shellcheck source=tpm/scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

usage() {
  echo "Usage: nv-counter.sh init | read | accept <version>" >&2
}

read_counter() {
  local hex
  hex="$(tpm2_nvread "$NV_INDEX" -C o -s 8 | od -An -tx1 | tr -d ' \n')"
  echo $((16#$hex))
}

base_file="$TPM_WORK/nv-baseline"

case "${1:-}" in
  init)
    tpm2_nvundefine "$NV_INDEX" -C o >/dev/null 2>&1 || true
    tpm2_nvdefine "$NV_INDEX" -C o -s 8 -a "nt=counter|ownerread|ownerwrite" >/dev/null
    tpm2_nvincrement "$NV_INDEX" -C o
    read_counter >"$base_file"
    echo "COUNTER $NV_INDEX baseline $(cat "$base_file")"
    ;;
  read)
    read_counter
    ;;
  accept)
    if (($# != 2)); then
      usage
      exit 2
    fi
    [[ "$2" =~ ^[0-9]+$ ]] || die "version must be a whole number"
    [[ -f "$base_file" ]] || die "run nv-counter.sh init first"
    base="$(cat "$base_file")"
    target=$((base + $2))
    current="$(read_counter)"
    if ((target < current)); then
      echo "rollback refused: version $2 is older than accepted version $((current - base))"
      exit 1
    fi
    while (($(read_counter) < target)); do
      tpm2_nvincrement "$NV_INDEX" -C o
    done
    echo "ACCEPTED version $2 counter=$(read_counter)"
    ;;
  -h | --help)
    usage
    ;;
  *)
    usage
    exit 2
    ;;
esac
