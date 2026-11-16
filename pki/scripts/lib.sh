#!/usr/bin/env bash
# Shared paths and helpers for the PKI scripts. Sourced, not executed.
# PKI_HOME holds key material. It must be a Docker volume or a temporary directory, never the repository.
set -euo pipefail

PKI_HOME="${PKI_HOME:-/pki}"
PKI_CONF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../openssl" && pwd)"
export PKI_ROOT_DIR="${PKI_ROOT_DIR:-$PKI_HOME/root}"
export PKI_INT_DIR="${PKI_INT_DIR:-$PKI_HOME/intermediate}"
export PKI_PUBLIC_DIR="${PKI_PUBLIC_DIR:-$PKI_HOME/public}"
export PKI_ISSUED_DIR="${PKI_ISSUED_DIR:-$PKI_HOME/issued}"
export SAN="${SAN:-DNS:unused.invalid}"
ROOT_CNF="$PKI_CONF_DIR/root.cnf"
INT_CNF="$PKI_CONF_DIR/intermediate.cnf"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ROOT_CNF INT_CNF SCRIPT_DIR PKI_HOME PKI_CONF_DIR

die() {
  echo "ERROR: $*" >&2
  exit 1
}

refuse_repo_path() {
  local repo target
  repo="$(realpath -m "$PKI_CONF_DIR/../..")"
  # realpath -m resolves relative and not yet created paths, so neither can slip past the check.
  target="$(realpath -m "$1")"
  case "$target" in
    "$repo" | "$repo"/*) die "refusing to keep key material inside the repository: $1" ;;
  esac
}

init_ca_dir() {
  local dir="$1"
  mkdir -p "$dir/private" "$dir/newcerts"
  chmod 700 "$dir/private"
  : >"$dir/index.txt"
  printf 'unique_subject = no\n' >"$dir/index.txt.attr"
  openssl rand -hex 16 >"$dir/serial"
  echo 1000 >"$dir/crlnumber"
}

# Every PKI script sources this file, so every script refuses a PKI_HOME inside the repository.
for _pki_dir in "$PKI_HOME" "$PKI_ROOT_DIR" "$PKI_INT_DIR" "$PKI_ISSUED_DIR"; do
  refuse_repo_path "$_pki_dir"
done
unset _pki_dir
