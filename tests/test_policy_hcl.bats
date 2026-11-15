setup() {
  CONFTEST_BIN="${CONFTEST_BIN:-conftest}"
  POLICY_ROOT="$BATS_TEST_DIRNAME/../policies/terraform"
}

@test "HCL policy denies Azure web apps without HTTPS and TLS 1.2" {
  run "$CONFTEST_BIN" test --no-color --parser hcl2 --policy "$POLICY_ROOT" --namespace terraform \
    "$POLICY_ROOT/fixtures/hcl/azure-webapp-http.tf"
  [ "$status" -eq 1 ]
  [[ "$output" == *"does not require HTTPS"* ]]
  [[ "$output" == *"TLS 1.2"* ]]
}

@test "HCL policy denies public GKE nodes and missing Workload Identity" {
  run "$CONFTEST_BIN" test --no-color --parser hcl2 --policy "$POLICY_ROOT" --namespace terraform \
    "$POLICY_ROOT/fixtures/hcl/gke-public.tf"
  [ "$status" -eq 1 ]
  [[ "$output" == *"private GKE nodes"* ]]
  [[ "$output" == *"Workload Identity"* ]]
}

@test "HCL policy denies public SSH and RDP port ranges" {
  run "$CONFTEST_BIN" test --no-color --parser hcl2 --policy "$POLICY_ROOT" --namespace terraform \
    "$POLICY_ROOT/fixtures/hcl/public-admin-port-ranges.tf"
  [ "$status" -eq 1 ]
  [[ "$output" == *"google_compute_firewall.public_admin_range exposes SSH"* ]]
  [[ "$output" == *"google_compute_firewall.public_admin_all_ports exposes RDP"* ]]
  [[ "$output" == *"azurerm_network_security_rule.public_admin_range exposes RDP"* ]]
  [[ "$output" == *"azurerm_network_security_rule.public_admin_ranges exposes SSH"* ]]
}
