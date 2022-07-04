resource "google_dns_managed_zone" "default" {
  name        = "week8"
  dns_name    = "week8challenge.tk."
  description = "Week 8 DNS"

  visibility = "public"
}

# reserved IP address
resource "google_compute_global_address" "default" {
  name         = "default-ip-reserved"
  address_type = "EXTERNAL"
}

resource "google_dns_record_set" "www-default" {
  name = "www.${google_dns_managed_zone.default.dns_name}"
  type = "CNAME"
  ttl  = 300

  managed_zone = google_dns_managed_zone.default.name

  rrdatas = [google_dns_managed_zone.default.dns_name]
}

resource "google_dns_record_set" "default" {
  name = google_dns_managed_zone.default.dns_name
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.default.name

  rrdatas = [google_compute_global_address.default.address] //google_compute_instance.frontend.network_interface[0].access_config[0].nat_ip
}

resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account Kubernetes"
}

resource "google_container_cluster" "primary" {
  name = "my-gke-cluster"

  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = "REGULAR"
  }
}

data "google_container_engine_versions" "default" {
  version_prefix = "1.24."
}

output "stable_channel_version" {
  value = data.google_container_engine_versions.default.release_channel_default_version["STABLE"]
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  cluster    = google_container_cluster.primary.name
  node_count = 2
  version    = data.google_container_engine_versions.default.release_channel_default_version["STABLE"]

  node_config {
    preemptible  = true
    machine_type = "e2-small"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

