package terraform

import rego.v1

has_expected_deny(fixture, fragment) if {
  some message in deny with input as fixture
  contains(message, fragment)
}

test_missing_required_tags_are_denied if {
  has_expected_deny(data.fixtures.deny.required_tags, "missing required")
}

test_open_ssh_is_denied if {
  has_expected_deny(data.fixtures.deny.open_ssh, "exposes SSH")
}

test_open_rdp_is_denied if {
  has_expected_deny(data.fixtures.deny.open_rdp, "exposes RDP")
}

test_public_storage_access_is_denied if {
  has_expected_deny(data.fixtures.deny.public_storage, "public S3 access")
}

test_unencrypted_storage_is_denied if {
  has_expected_deny(data.fixtures.deny.unencrypted_storage, "S3 encryption")
}

test_wildcard_iam_actions_are_denied if {
  has_expected_deny(data.fixtures.deny.wildcard_iam_action, "wildcard IAM action")
}

test_wildcard_iam_resources_are_denied if {
  has_expected_deny(data.fixtures.deny.wildcard_iam_resource, "wildcard IAM resource")
}

test_oidc_trust_without_subject_condition_is_denied if {
  has_expected_deny(data.fixtures.deny.oidc_without_subject, "without a subject condition")
}

test_public_gke_nodes_are_denied if {
  has_expected_deny(data.fixtures.deny.public_gke_nodes, "private GKE nodes")
}

test_gke_without_workload_identity_is_denied if {
  has_expected_deny(data.fixtures.deny.gke_without_workload_identity, "Workload Identity")
}

test_azure_http_is_denied if {
  has_expected_deny(data.fixtures.deny.azure_http, "require HTTPS")
}

test_azure_old_tls_is_denied if {
  has_expected_deny(data.fixtures.deny.azure_old_tls, "TLS 1.2")
}

test_static_cloud_keys_are_denied if {
  has_expected_deny(data.fixtures.deny.static_cloud_key, "static cloud credential")
}

test_disallowed_regions_are_denied if {
  has_expected_deny(data.fixtures.deny.disallowed_region, "disallowed region")
}

test_vpc_without_flow_logs_is_denied if {
  has_expected_deny(data.fixtures.deny.vpc_without_flow_logs, "no VPC flow log")
}

test_prod_without_deletion_protection_is_denied if {
  has_expected_deny(data.fixtures.deny.prod_without_deletion_protection, "production deletion protection")
}
