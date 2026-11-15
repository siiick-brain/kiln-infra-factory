#!/usr/bin/env bash
# Prints the content for one terminal screenshot. Called by scripts/capture-all.ps1 inside the toolbox.
# Recorded-run images print lines from artifacts/logs. Live images run the check now.
set -euo pipefail

usage() {
  echo "Usage: scripts/shot-source.sh <image-name>" >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -ne 1 ]]; then
  usage
  [[ $# -eq 1 ]] && exit 0
  exit 2
fi

logs=artifacts/logs
case "$1" in
  tb-versions) bash scripts/toolbox-versions.sh ;;
  tf-validate-all) cat "$logs/test-modules.log" ;;
  terraform-test)
    # Terraform colours its output, so strip the escape codes before matching.
    for f in "$logs"/modules/*.log; do
      printf '%-50s %s\n' "$(basename "$f" .log)" \
        "$(sed 's/\x1b\[[0-9;]*m//g' "$f" | grep -o 'Success! [0-9]* passed, [0-9]* failed' | tail -1)"
    done
    ;;
  conftest-pass)
    conftest test --no-color --parser hcl2 --namespace terraform --ignore '\.terraform|\.terragrunt-cache' \
      -p policies/terraform modules live | tail -3
    ;;
  conftest-deny)
    conftest test --no-color --parser hcl2 --namespace terraform -p policies/terraform \
      policies/terraform/fixtures/hcl | tail -16 || true
    ;;
  terragrunt-plan) cat "$logs/terragrunt-run-all.log" ;;
  remote-state)
    grep -E 'Successfully configured|migration_probe|verified|refused|Error acquiring' "$logs/migrate-state.log" | head -12
    ;;
  drift-detected) cat "$logs/drift-demo.log" ;;
  ansible-recap) grep -E 'PLAY RECAP|rocky-target-[12] +:|Passed:|passed in' "$logs/test-ansible.log" ;;
  pki-chain-verify) bats tests/test_pki.bats ;;
  pki-revoked-crl) bats -f 'CRL check' tests/test_pki.bats ;;
  ocsp-revoked) bats -f 'OCSP' tests/test_pki.bats ;;
  cert-rotation) cat "$logs/test-pki-deploy.log" ;;
  tpm-unseal-ok) grep -E '^(ok|not ok|1\.\.)' "$logs/test-tpm.log" ;;
  tpm-unseal-fail) grep -E 'unseal|extended' "$logs/test-tpm.log" ;;
  sops-encrypted)
    head -4 secrets/demo.enc.yaml | cut -c1-110
    bats tests/test_sops.bats
    ;;
  kind-apply) grep -E '^(PASS|FAIL)|kind:|rolled out' "$logs/kind-apply.log" ;;
  k8s-certs-verify) bats tests/test_pki_k8s.bats ;;
  tests-green)
    for f in test-modules test-pki test-pki-k8s test-tpm test-sops test-bash test-promote opa-test conftest-hcl checkov-summary; do
      printf '%-16s %s\n' "$f" "$(grep -vE '^\s*$' "$logs/$f.log" | tail -1 | cut -c1-90)"
    done
    ;;
  *)
    echo "Unknown image: $1" >&2
    exit 2
    ;;
esac
