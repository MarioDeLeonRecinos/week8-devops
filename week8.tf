resource "google_compute_network" "vpc_network" {
  name                    = "vpc-network"
  auto_create_subnetworks = true
  mtu                     = 1460
}

resource "google_compute_network" "vpc_network-test" {
  name                    = "vpc-network-test"
  auto_create_subnetworks = true
  mtu                     = 1460
}

module "dns-provider" {
  source = "./modules/dns-provider"

  name     = "week-8"
  dns_name = "week8challenge.tk."
  labels = {
    creator = "mario",
    owner   = "mario"
  }
  subdomain = ["dash", "monitor"]
}

module "kubernetes-provider" {
  source = "./modules/kubernetes-provider"

  name                 = "my-gke-cluster"
  name_node_pool       = "my-node-pool"
  service_account_name = "service-account-id"
  machine_type         = "e2-small"
  vpc_network          = google_compute_network.vpc_network.name
  labels = {
    creator = "mario",
    owner   = "mario"
  }
  tags = ["dash", "monitor"]
}