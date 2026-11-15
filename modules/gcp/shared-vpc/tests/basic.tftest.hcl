mock_provider "google" {}

run "creates_shared_vpc_with_default_denies" {
  command = plan

  variables {
    host_project_id        = "host-test"
    service_project_id     = "service-test"
    service_project_number = "123456789012"
    network_name           = "test-shared-network"
    region                 = "us-central1"
    subnet_cidr            = "10.40.0.0/20"
    labels = {
      environment = "test"
      owner       = "siiick-brain"
      project     = "kiln-infra-factory"
    }
  }

  assert {
    condition     = one(google_compute_firewall.deny_ingress.deny).protocol == "all"
    error_message = "Ingress must deny all traffic by default."
  }

  assert {
    condition     = one(google_compute_firewall.deny_egress.deny).protocol == "all"
    error_message = "Egress must deny all traffic by default."
  }

  assert {
    condition     = contains(google_compute_firewall.deny_ingress.target_tags, "kiln-workload") && contains(google_compute_firewall.deny_egress.target_tags, "kiln-workload")
    error_message = "Default-deny firewalls must target the shared workload tag."
  }
}

run "rejects_network_tags_without_the_deny_target" {
  command = plan

  variables {
    host_project_id        = "host-test"
    service_project_id     = "service-test"
    service_project_number = "123456789012"
    network_name           = "test-shared-network"
    region                 = "us-central1"
    subnet_cidr            = "10.40.0.0/20"
    network_tags           = ["custom-workload"]
    labels = {
      environment = "test"
      owner       = "siiick-brain"
      project     = "kiln-infra-factory"
    }
  }

  expect_failures = [var.network_tags]
}
