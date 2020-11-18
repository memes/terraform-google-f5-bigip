terraform {
  required_version = "~> 0.12.29"
  required_providers {
    google = ">= 3.48"
  }
  experiments = [variable_validation]
}

# Create a pair of service account limited firewall rules that support ConfigSync
# between BIG-IP instances

# Allow BIG-IP instances to connect on management network
resource "google_compute_firewall" "mgt_sync" {
  project                 = var.project_id
  name                    = var.management_firewall_name
  network                 = var.management_network
  description             = "ConfigSync for management network"
  direction               = "INGRESS"
  source_service_accounts = [var.bigip_service_account]
  target_service_accounts = [var.bigip_service_account]
  allow {
    protocol = "tcp"
    ports = [
      443,
    ]
  }
}

# Allow BIG-IP instances to connect and sync on data-plane network
resource "google_compute_firewall" "data_sync" {
  project                 = var.project_id
  name                    = var.dataplane_firewall_name
  network                 = var.dataplane_network
  description             = "ConfigSync for data-plane network"
  direction               = "INGRESS"
  source_service_accounts = [var.bigip_service_account]
  target_service_accounts = [var.bigip_service_account]
  allow {
    protocol = "tcp"
    ports = [
      443,
      4353,
      "6123-6128",
    ]
  }
  allow {
    protocol = "udp"
    ports = [
      1026,
    ]
  }
}
