package terraform

import rego.v1

taggable_resource_types := {
  "aws_cloudwatch_log_group",
  "aws_eip",
  "aws_flow_log",
  "aws_iam_openid_connect_provider",
  "aws_iam_role",
  "aws_internet_gateway",
  "aws_lambda_function",
  "aws_nat_gateway",
  "aws_s3_bucket",
  "aws_security_group",
  "aws_subnet",
  "aws_sqs_queue",
  "aws_vpc",
  "azurerm_key_vault",
  "azurerm_linux_web_app",
  "azurerm_nat_gateway",
  "azurerm_network_security_group",
  "azurerm_public_ip",
  "azurerm_service_plan",
  "azurerm_storage_account",
  "azurerm_virtual_network",
  "google_container_cluster",
  "google_storage_bucket",
}

required_tag_names := {"Environment", "Owner", "Project"}

allowed_regions := {
  "centralus",
  "eastus",
  "eu-west-1",
  "us-central1",
  "us-east-1",
  "us-east1",
  "us-west-2",
}

resource_changes := object.get(input, "resource_changes", [])

resource_after(resource) := after if {
  after := object.get(object.get(resource, "change", {}), "after", null)
  is_object(after)
}

has_required_tags(resource) if {
  tags := object.get(resource, "tags", object.get(resource, "resource_labels", object.get(resource, "labels", {})))
  is_object(tags)
  every key in required_tag_names {
    value := object.get(tags, key, object.get(tags, lower(key), ""))
    is_string(value)
    value != ""
  }
}

deny contains message if {
  some resource in resource_changes
  resource.type in taggable_resource_types
  after := resource_after(resource)
  not has_required_tags(after)
  message := sprintf("%s is missing required Environment, Owner or Project tags", [resource.address])
}

port_is_in_range(rule, port) if {
  object.get(rule, "protocol", "") == "-1"
}

port_is_in_range(rule, port) if {
  from_port := object.get(rule, "from_port", -1)
  to_port := object.get(rule, "to_port", -1)
  from_port <= port
  to_port >= port
}

public_ipv4(rule) if {
  "0.0.0.0/0" in object.get(rule, "cidr_blocks", [])
}

public_ipv4(rule) if {
  "0.0.0.0/0" in object.get(rule, "source_ranges", [])
}

public_ipv4(rule) if {
  object.get(rule, "source_address_prefix", "") in {"*", "Internet", "0.0.0.0/0"}
}

exposes_admin_port(resource, port) if {
  after := resource_after(resource)
  resource.type in {"aws_security_group", "google_compute_firewall"}
  rules := object.get(after, "ingress", object.get(after, "allowed", []))
  some rule in rules
  public_ipv4(rule)
  port_is_in_range(rule, port)
}

exposes_admin_port(resource, port) if {
  after := resource_after(resource)
  resource.type == "google_compute_firewall"
  public_ipv4(after)
  rules := object.get(after, "allow", [])
  some rule in rules
  ports := object.get(rule, "ports", [])
  port_string := sprintf("%d", [port])
  port_string in ports
}

exposes_admin_port(resource, port) if {
  after := resource_after(resource)
  resource.type == "google_compute_firewall"
  public_ipv4(after)
  rules := object.get(after, "allow", [])
  some rule in rules
  object.get(rule, "IPProtocol", object.get(rule, "ip_protocol", "")) == "all"
  object.get(rule, "ports", []) == []
}

exposes_admin_port(resource, port) if {
  after := resource_after(resource)
  resource.type == "aws_security_group_rule"
  public_ipv4(after)
  port_is_in_range(after, port)
}

exposes_admin_port(resource, port) if {
  after := resource_after(resource)
  resource.type == "azurerm_network_security_rule"
  object.get(after, "access", "") == "Allow"
  public_ipv4(after)
  ranges := object.get(after, "destination_port_ranges", [])
  port_string := sprintf("%d", [port])
  port_string in ranges
}

exposes_admin_port(resource, port) if {
  after := resource_after(resource)
  resource.type == "azurerm_network_security_rule"
  object.get(after, "access", "") == "Allow"
  public_ipv4(after)
  range := object.get(after, "destination_port_range", "")
  port_string := sprintf("%d", [port])
  range == port_string
}

exposes_admin_port(resource, port) if {
  after := resource_after(resource)
  resource.type == "azurerm_network_security_rule"
  object.get(after, "access", "") == "Allow"
  public_ipv4(after)
  range := object.get(after, "destination_port_range", "")
  range == "*"
}

deny contains message if {
  some resource in resource_changes
  exposes_admin_port(resource, 22)
  message := sprintf("%s exposes SSH to 0.0.0.0/0", [resource.address])
}

deny contains message if {
  some resource in resource_changes
  exposes_admin_port(resource, 3389)
  message := sprintf("%s exposes RDP to 0.0.0.0/0", [resource.address])
}

deny contains message if {
  some resource in resource_changes
  resource.type == "aws_s3_bucket_public_access_block"
  after := resource_after(resource)
  some flag in {"block_public_acls", "block_public_policy", "ignore_public_acls", "restrict_public_buckets"}
  object.get(after, flag, false) != true
  message := sprintf("%s does not block all public S3 access", [resource.address])
}

deny contains message if {
  some resource in resource_changes
  resource.type == "google_storage_bucket"
  after := resource_after(resource)
  object.get(after, "public_access_prevention", "") != "enforced"
  message := sprintf("%s does not enforce public access prevention", [resource.address])
}

resource_name(address) := name if {
  parts := split(address, ".")
  name := parts[count(parts) - 1]
}

has_s3_encryption(bucket, changes) if {
  some encryption in changes
  encryption.type == "aws_s3_bucket_server_side_encryption_configuration"
  resource_name(encryption.address) == resource_name(bucket.address)
  after := resource_after(encryption)
  rules := object.get(after, "rule", [])
  some rule in rules
  defaults := object.get(rule, "apply_server_side_encryption_by_default", [])
  some config in defaults
  algorithm := object.get(config, "sse_algorithm", "")
  algorithm in {"AES256", "aws:kms", "aws:kms:dsse"}
}

deny contains message if {
  some resource in resource_changes
  resource.type == "aws_s3_bucket"
  resource_after(resource)
  not has_s3_encryption(resource, resource_changes)
  message := sprintf("%s has no matching S3 encryption configuration", [resource.address])
}

policy_document(resource) := document if {
  after := resource_after(resource)
  policy := object.get(after, "policy", "")
  is_string(policy)
  document := json.unmarshal(policy)
}

policy_statements(document) := statements if {
  statements := object.get(document, "Statement", [])
  is_array(statements)
}

policy_statements(document) := [statement] if {
  statement := object.get(document, "Statement", {})
  is_object(statement)
}

wildcard_string(value) if {
  is_string(value)
  contains(value, "*")
}

has_wildcard_action(value) if {
  wildcard_string(value)
}

has_wildcard_action(values) if {
  is_array(values)
  some value in values
  wildcard_string(value)
}

is_unscoped_wildcard(value) if {
  value == "*"
}

is_unscoped_wildcard(values) if {
  is_array(values)
  some value in values
  value == "*"
}

deny contains message if {
  some resource in resource_changes
  resource.type in {"aws_iam_policy", "aws_iam_role_policy", "aws_iam_user_policy"}
  document := policy_document(resource)
  statements := policy_statements(document)
  some statement in statements
  actions := object.get(statement, "Action", [])
  has_wildcard_action(actions)
  message := sprintf("%s has a wildcard IAM action", [resource.address])
}

deny contains message if {
  some resource in resource_changes
  resource.type in {"aws_iam_policy", "aws_iam_role_policy", "aws_iam_user_policy"}
  document := policy_document(resource)
  statements := policy_statements(document)
  some statement in statements
  resources := object.get(statement, "Resource", [])
  is_unscoped_wildcard(resources)
  message := sprintf("%s grants an unscoped wildcard IAM resource", [resource.address])
}

deny contains message if {
  some resource in resource_changes
  resource.type == "aws_iam_role"
  after := resource_after(resource)
  trust := json.unmarshal(object.get(after, "assume_role_policy", "{}"))
  statements := object.get(trust, "Statement", [])
  some statement in statements
  principal := object.get(statement, "Principal", {})
  object.get(principal, "Federated", "") != ""
  not has_oidc_subject_condition(statement)
  message := sprintf("%s has federated trust without a subject condition", [resource.address])
}

has_oidc_subject_condition(statement) if {
  conditions := object.get(statement, "Condition", {})
  some operator, values in conditions
  some key in object.keys(values)
  endswith(key, ":sub")
}

has_private_gke_nodes(configs) if {
  some config in configs
  object.get(config, "enable_private_nodes", false) == true
}

deny contains message if {
  some resource in resource_changes
  resource.type == "google_container_cluster"
  after := resource_after(resource)
  private_config := object.get(after, "private_cluster_config", [])
  not has_private_gke_nodes(private_config)
  message := sprintf("%s does not use private GKE nodes", [resource.address])
}

has_workload_identity(configs) if {
  some config in configs
  object.get(config, "workload_pool", "") != ""
}

deny contains message if {
  some resource in resource_changes
  resource.type == "google_container_cluster"
  after := resource_after(resource)
  identity_config := object.get(after, "workload_identity_config", [])
  not has_workload_identity(identity_config)
  message := sprintf("%s does not enable GKE Workload Identity", [resource.address])
}

deny contains message if {
  some resource in resource_changes
  resource.type in {"azurerm_linux_web_app", "azurerm_windows_web_app"}
  after := resource_after(resource)
  object.get(after, "https_only", false) != true
  message := sprintf("%s does not require HTTPS", [resource.address])
}

has_modern_tls(site_configs) if {
  some config in site_configs
  object.get(config, "minimum_tls_version", "") in {"1.2", "1.3"}
}

deny contains message if {
  some resource in resource_changes
  resource.type in {"azurerm_linux_web_app", "azurerm_windows_web_app"}
  after := resource_after(resource)
  site_configs := object.get(after, "site_config", [])
  not has_modern_tls(site_configs)
  message := sprintf("%s does not require TLS 1.2 or newer", [resource.address])
}

deny contains message if {
  some resource in resource_changes
  resource.type in {"aws_iam_access_key", "google_service_account_key", "azurerm_service_principal_password"}
  resource_after(resource)
  message := sprintf("%s creates a static cloud credential", [resource.address])
}

deny contains message if {
  some resource in resource_changes
  after := resource_after(resource)
  region := object.get(after, "region", object.get(after, "location", ""))
  region != ""
  not is_allowed_region(region)
  message := sprintf("%s uses disallowed region %s", [resource.address, region])
}

is_allowed_region(region) if {
  lower(region) in allowed_regions
}

has_vpc_flow_log(changes) if {
  some flow_log in changes
  flow_log.type == "aws_flow_log"
  resource_after(flow_log)
}

deny contains message if {
  some resource in resource_changes
  resource.type == "aws_vpc"
  resource_after(resource)
  not has_vpc_flow_log(resource_changes)
  message := sprintf("%s has no VPC flow log", [resource.address])
}

is_production(resource) if {
  object.get(input, "environment", "") == "prod"
}

is_production(resource) if {
  after := resource_after(resource)
  tags := object.get(after, "tags", object.get(after, "resource_labels", object.get(after, "labels", {})))
  lower(object.get(tags, "Environment", object.get(tags, "environment", ""))) == "prod"
}

deny contains message if {
  some resource in resource_changes
  resource.type in {"aws_db_instance", "aws_rds_cluster", "google_container_cluster", "azurerm_kubernetes_cluster"}
  after := resource_after(resource)
  is_production(resource)
  object.get(after, "deletion_protection", false) != true
  message := sprintf("%s lacks production deletion protection", [resource.address])
}
