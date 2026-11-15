package terraform

import rego.v1

hcl_resources := object.get(input, "resource", {})

hcl_has_required_tags(tags) if {
	is_object(tags)
	every key in required_tag_names {
		value := object.get(tags, key, object.get(tags, lower(key), ""))
		is_string(value)
		value != ""
	}
}

deny contains message if {
	some resource_type, named_resources in hcl_resources
	resource_type in taggable_resource_types
	some resource_name, blocks in named_resources
	some block in blocks
	tags := object.get(block, "tags", object.get(block, "resource_labels", object.get(block, "labels", {})))
	is_object(tags)
	not hcl_has_required_tags(tags)
	message := sprintf("%s.%s is missing required tags", [resource_type, resource_name])
}

hcl_port_is_exposed(rule, port) if {
	object.get(rule, "protocol", object.get(rule, "ip_protocol", "")) == "-1"
}

hcl_port_is_exposed(rule, port) if {
	object.get(rule, "ip_protocol", "") == "all"
}

hcl_port_is_exposed(rule, port) if {
	from_port := object.get(rule, "from_port", -1)
	to_port := object.get(rule, "to_port", -1)
	from_port <= port
	to_port >= port
}

hcl_port_range_contains(range, port) if {
	range == "*"
}

hcl_port_range_contains(range, port) if {
	range == sprintf("%d", [port])
}

hcl_port_range_contains(range, port) if {
	is_string(range)
	parts := split(range, "-")
	count(parts) == 2
	lower := to_number(parts[0])
	upper := to_number(parts[1])
	lower <= port
	upper >= port
}

hcl_exposes_admin_port(resource_type, block, port) if {
	resource_type == "aws_security_group"
	some rule in object.get(block, "ingress", [])
	public_ipv4(rule)
	hcl_port_is_exposed(rule, port)
}

hcl_exposes_admin_port(resource_type, block, port) if {
	resource_type == "google_compute_firewall"
	"0.0.0.0/0" in object.get(block, "source_ranges", [])
	some rule in object.get(block, "allow", [])
	ports := object.get(rule, "ports", [])
	some port_range in ports
	hcl_port_range_contains(port_range, port)
}

hcl_exposes_admin_port(resource_type, block, port) if {
	resource_type == "google_compute_firewall"
	"0.0.0.0/0" in object.get(block, "source_ranges", [])
	some rule in object.get(block, "allow", [])
	object.get(rule, "protocol", object.get(rule, "ip_protocol", "")) in {"all", "tcp", "udp"}
	object.get(rule, "ports", []) == []
}

hcl_exposes_admin_port(resource_type, block, port) if {
	resource_type == "azurerm_network_security_rule"
	object.get(block, "access", "") == "Allow"
	object.get(block, "source_address_prefix", "") in {"*", "Internet", "0.0.0.0/0"}
	range := object.get(block, "destination_port_range", "")
	hcl_port_range_contains(range, port)
}

hcl_exposes_admin_port(resource_type, block, port) if {
	resource_type == "azurerm_network_security_rule"
	object.get(block, "access", "") == "Allow"
	prefixes := object.get(block, "source_address_prefixes", [])
	some prefix in prefixes
	prefix in {"*", "Internet", "0.0.0.0/0"}
	ranges := object.get(block, "destination_port_ranges", [])
	some range in ranges
	hcl_port_range_contains(range, port)
}

deny contains message if {
	some resource_type, named_resources in hcl_resources
	some resource_name, blocks in named_resources
	some block in blocks
	hcl_exposes_admin_port(resource_type, block, 22)
	message := sprintf("%s.%s exposes SSH to 0.0.0.0/0", [resource_type, resource_name])
}

deny contains message if {
	some resource_type, named_resources in hcl_resources
	some resource_name, blocks in named_resources
	some block in blocks
	hcl_exposes_admin_port(resource_type, block, 3389)
	message := sprintf("%s.%s exposes RDP to 0.0.0.0/0", [resource_type, resource_name])
}

deny contains message if {
	some resource_type, named_resources in hcl_resources
	resource_type == "google_storage_bucket"
	some resource_name, blocks in named_resources
	some block in blocks
	object.get(block, "public_access_prevention", "") != "enforced"
	message := sprintf("%s.%s does not enforce public access prevention", [resource_type, resource_name])
}

deny contains message if {
	some resource_type, named_resources in hcl_resources
	resource_type in {"azurerm_linux_web_app", "azurerm_windows_web_app"}
	some resource_name, blocks in named_resources
	some block in blocks
	object.get(block, "https_only", false) != true
	message := sprintf("%s.%s does not require HTTPS", [resource_type, resource_name])
}

hcl_has_modern_tls(site_configs) if {
	some config in site_configs
	object.get(config, "minimum_tls_version", "") in {"1.2", "1.3"}
}

deny contains message if {
	some resource_type, named_resources in hcl_resources
	resource_type in {"azurerm_linux_web_app", "azurerm_windows_web_app"}
	some resource_name, blocks in named_resources
	some block in blocks
	site_configs := object.get(block, "site_config", [])
	not hcl_has_modern_tls(site_configs)
	message := sprintf("%s.%s does not require TLS 1.2 or newer", [resource_type, resource_name])
}

hcl_has_private_gke_nodes(configs) if {
	some config in configs
	object.get(config, "enable_private_nodes", false) == true
}

deny contains message if {
	some resource_type, named_resources in hcl_resources
	resource_type == "google_container_cluster"
	some resource_name, blocks in named_resources
	some block in blocks
	not hcl_has_private_gke_nodes(object.get(block, "private_cluster_config", []))
	message := sprintf("%s.%s does not use private GKE nodes", [resource_type, resource_name])
}

hcl_has_workload_identity(configs) if {
	some config in configs
	object.get(config, "workload_pool", "") != ""
}

deny contains message if {
	some resource_type, named_resources in hcl_resources
	resource_type == "google_container_cluster"
	some resource_name, blocks in named_resources
	some block in blocks
	not hcl_has_workload_identity(object.get(block, "workload_identity_config", []))
	message := sprintf("%s.%s does not enable GKE Workload Identity", [resource_type, resource_name])
}

deny contains message if {
	some resource_type, named_resources in hcl_resources
	resource_type in {"aws_iam_access_key", "google_service_account_key", "azurerm_service_principal_password"}
	some resource_name, _ in named_resources
	message := sprintf("%s.%s creates a static cloud credential", [resource_type, resource_name])
}

deny contains message if {
	some resource_type, named_resources in hcl_resources
	some resource_name, blocks in named_resources
	some block in blocks
	region := object.get(block, "region", object.get(block, "location", ""))
	is_string(region)
	not startswith(region, "${")
	region != ""
	not is_allowed_region(region)
	message := sprintf("%s.%s uses disallowed region %s", [resource_type, resource_name, region])
}
