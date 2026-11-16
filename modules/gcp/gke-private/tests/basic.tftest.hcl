mock_provider "google" {}

run "requires_private_nodes_and_identity" {
  command = plan

  variables {
    project_id             = "project-test"
    name                   = "test-cluster"
    region                 = "us-central1"
    network                = "projects/host-test/global/networks/shared"
    subnetwork             = "projects/host-test/regions/us-central1/subnetworks/service"
    master_ipv4_cidr_block = "172.16.0.0/28"
    authorized_networks    = ["10.40.0.0/20"]
    labels = {
      environment = "test"
      owner       = "siiick-brain"
      project     = "kiln-infra-factory"
    }
  }

  assert {
    condition     = google_container_cluster.private.private_cluster_config[0].enable_private_nodes
    error_message = "GKE nodes must be private."
  }

  assert {
    condition     = google_container_node_pool.private.node_config[0].metadata["disable-legacy-endpoints"] == "true"
    error_message = "GKE nodes must disable the legacy metadata endpoints."
  }

  assert {
    condition     = google_container_cluster.private.workload_identity_config[0].workload_pool == "project-test.svc.id.goog"
    error_message = "GKE Workload Identity must be enabled."
  }

  assert {
    condition     = contains(google_container_node_pool.private.node_config[0].tags, "kiln-workload")
    error_message = "GKE nodes must use the tag targeted by Shared VPC default-deny rules."
  }

  assert {
    condition     = google_project_iam_member.node_logging.role == "roles/logging.logWriter" && google_project_iam_member.node_monitoring.role == "roles/monitoring.metricWriter"
    error_message = "GKE node service account permissions must remain limited to logging and monitoring."
  }
}

run "rejects_network_tags_without_the_deny_target" {
  command = plan

  variables {
    project_id             = "project-test"
    name                   = "test-cluster"
    region                 = "us-central1"
    network                = "projects/host-test/global/networks/shared"
    subnetwork             = "projects/host-test/regions/us-central1/subnetworks/service"
    master_ipv4_cidr_block = "172.16.0.0/28"
    authorized_networks    = ["10.40.0.0/20"]
    network_tags           = ["custom-workload"]
    labels = {
      environment = "test"
      owner       = "siiick-brain"
      project     = "kiln-infra-factory"
    }
  }

  expect_failures = [var.network_tags]
}

run "binds_kubernetes_service_account_to_google_service_account" {
  command = apply

  variables {
    project_id             = "project-test"
    name                   = "test-cluster"
    region                 = "us-central1"
    network                = "projects/host-test/global/networks/shared"
    subnetwork             = "projects/host-test/regions/us-central1/subnetworks/service"
    master_ipv4_cidr_block = "172.16.0.0/28"
    authorized_networks    = ["10.40.0.0/20"]
    workload_identity_bindings = [{
      service_account_email      = "app-deploy@project-test.iam.gserviceaccount.com"
      namespace                  = "app"
      kubernetes_service_account = "app"
    }]
    labels = {
      environment = "test"
      owner       = "siiick-brain"
      project     = "kiln-infra-factory"
    }
  }

  assert {
    condition     = google_service_account_iam_member.gke_workload_identity["app/app"].role == "roles/iam.workloadIdentityUser"
    error_message = "Kubernetes Workload Identity must grant only the workload identity user role."
  }

  assert {
    condition     = google_service_account_iam_member.gke_workload_identity["app/app"].member == "serviceAccount:project-test.svc.id.goog[app/app]"
    error_message = "The binding must identify the exact Kubernetes namespace and service account."
  }
}
