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

# Regression tests from the checkpoint review (M7 and M8).
tags := {"Environment": "test", "Owner": "siiick-brain", "Project": "kiln-infra-factory"}

change(address, type, after) := {"address": address, "type": type, "change": {"actions": ["create"], "after": after}}

test_azure_port_range_with_ssh_is_denied if {
	plan := {"resource_changes": [change("azurerm_network_security_rule.wide", "azurerm_network_security_rule", {"access": "Allow", "source_address_prefix": "*", "destination_port_range": "0-65535"})]}
	has_expected_deny(plan, "exposes SSH")
}

test_gcp_tcp_without_ports_is_denied if {
	plan := {"resource_changes": [change("google_compute_firewall.wide", "google_compute_firewall", {"source_ranges": ["0.0.0.0/0"], "allow": [{"protocol": "tcp", "ports": []}], "labels": {"environment": "test", "owner": "o", "project": "p"}})]}
	has_expected_deny(plan, "exposes SSH")
}

test_ipv6_any_source_is_denied if {
	plan := {"resource_changes": [change("aws_security_group_rule.v6", "aws_security_group_rule", {"type": "ingress", "from_port": 22, "to_port": 22, "ipv6_cidr_blocks": ["::/0"]})]}
	has_expected_deny(plan, "exposes SSH")
}

test_encryption_in_another_module_does_not_cover_a_bucket if {
	plan := {"resource_changes": [
		change("module.state.aws_s3_bucket.this", "aws_s3_bucket", {"tags": tags}),
		change("module.state.aws_s3_bucket_server_side_encryption_configuration.this", "aws_s3_bucket_server_side_encryption_configuration", {"rule": [{"apply_server_side_encryption_by_default": [{"sse_algorithm": "AES256"}]}]}),
		change("module.logs.aws_s3_bucket.this", "aws_s3_bucket", {"tags": tags}),
	]}
	some message in deny with input as plan
	contains(message, "module.logs.aws_s3_bucket.this")
	contains(message, "S3 encryption")
}

test_flow_log_in_another_module_does_not_cover_a_vpc if {
	plan := {"resource_changes": [
		change("module.a.aws_vpc.this", "aws_vpc", {"tags": tags}),
		change("module.a.aws_flow_log.this", "aws_flow_log", {"tags": tags}),
		change("module.b.aws_vpc.this", "aws_vpc", {"tags": tags}),
	]}
	some message in deny with input as plan
	contains(message, "module.b.aws_vpc.this")
}

test_clean_plan_has_no_denies if {
	plan := {"resource_changes": [
		change("module.a.aws_vpc.this", "aws_vpc", {"tags": tags}),
		change("module.a.aws_flow_log.this", "aws_flow_log", {"tags": tags}),
		change("module.a.aws_s3_bucket.this", "aws_s3_bucket", {"tags": tags}),
		change("module.a.aws_s3_bucket_server_side_encryption_configuration.this", "aws_s3_bucket_server_side_encryption_configuration", {"rule": [{"apply_server_side_encryption_by_default": [{"sse_algorithm": "AES256"}]}]}),
		change("module.a.aws_s3_bucket_public_access_block.this", "aws_s3_bucket_public_access_block", {"block_public_acls": true, "block_public_policy": true, "ignore_public_acls": true, "restrict_public_buckets": true}),
	]}
	count(deny) == 0 with input as plan
}
