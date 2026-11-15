resource "google_compute_network" "shared" {
  project                 = var.host_project_id
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_shared_vpc_host_project" "host" {
  project = var.host_project_id
}

resource "google_compute_shared_vpc_service_project" "service" {
  host_project    = google_compute_shared_vpc_host_project.host.project
  service_project = var.service_project_id
}

resource "google_compute_subnetwork" "service" {
  project                  = var.host_project_id
  name                     = "${var.network_name}-service"
  region                   = var.region
  network                  = google_compute_network.shared.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork_iam_member" "network_user" {
  project    = var.host_project_id
  region     = var.region
  subnetwork = google_compute_subnetwork.service.name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:service-${var.service_project_number}@compute-system.iam.gserviceaccount.com"
}

resource "google_compute_router" "nat" {
  project = var.host_project_id
  name    = "${var.network_name}-router"
  region  = var.region
  network = google_compute_network.shared.id
}

resource "google_compute_router_nat" "nat" {
  project                            = var.host_project_id
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.nat.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.service.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

resource "google_compute_firewall" "deny_ingress" {
  project       = var.host_project_id
  name          = "${var.network_name}-deny-ingress"
  network       = google_compute_network.shared.name
  direction     = "INGRESS"
  priority      = 65534
  target_tags   = var.network_tags
  source_ranges = ["0.0.0.0/0"]
  deny {
    protocol = "all"
  }
}

resource "google_compute_firewall" "deny_egress" {
  project            = var.host_project_id
  name               = "${var.network_name}-deny-egress"
  network            = google_compute_network.shared.name
  direction          = "EGRESS"
  priority           = 65534
  target_tags        = var.network_tags
  destination_ranges = ["0.0.0.0/0"]
  deny {
    protocol = "all"
  }
}
