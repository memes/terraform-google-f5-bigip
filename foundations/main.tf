# This module has been tested with Terraform 0.12.x only.
terraform {
  required_version = "~> 0.12"
  backend "gcs" {
    bucket = "tf-f5-gcs-4138-sales-cloud-sales"
    prefix = "emes/tf-modules/foundations"
  }
}

provider "google" {
  version = "~> 3.19"
}

# Create the service account(s) to be used in the project
module "service_accounts" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "2.0.2"
  project_id = "f5-gcs-4138-sales-cloud-sales"
  prefix     = "emes-tf-module"
  names      = ["bigip"]
  project_roles = [
    "${"f5-gcs-4138-sales-cloud-sales"}=>roles/logging.logWriter",
    "${"f5-gcs-4138-sales-cloud-sales"}=>roles/monitoring.metricWriter",
    "${"f5-gcs-4138-sales-cloud-sales"}=>roles/monitoring.viewer"
  ]
  generate_keys = false
}

# Create 8 networks for module testing

# Alpha - allows internet egress if the instance(s) have public IPs
module "alpha" {
  source       = "terraform-google-modules/network/google"
  version      = "2.3.0"
  project_id   = "f5-gcs-4138-sales-cloud-sales"
  network_name = "emes-tf-module-alpha"
  subnets = [
    {
      subnet_name                            = "alpha-west"
      subnet_ip                              = "172.16.0.0/16"
      subnet_region                          = "us-west1"
      delete_default_internet_gateway_routes = false
      subnet_private_access                  = false
    }
  ]
}

# Beta - no default routes, a NAT gateway will be provisioned to support egress
module "beta" {
  source       = "terraform-google-modules/network/google"
  version      = "2.3.0"
  project_id   = "f5-gcs-4138-sales-cloud-sales"
  network_name = "emes-tf-module-beta"
  subnets = [
    {
      subnet_name                            = "beta-west"
      subnet_ip                              = "172.17.0.0/16"
      subnet_region                          = "us-west1"
      delete_default_internet_gateway_routes = true
      subnet_private_access                  = true
    }
  ]
}

# Gamma - no default routes
module "gamma" {
  source       = "terraform-google-modules/network/google"
  version      = "2.3.0"
  project_id   = "f5-gcs-4138-sales-cloud-sales"
  network_name = "emes-tf-module-gamma"
  subnets = [
    {
      subnet_name                            = "gamma-west"
      subnet_ip                              = "172.18.0.0/16"
      subnet_region                          = "us-west1"
      delete_default_internet_gateway_routes = true
      subnet_private_access                  = true
    }
  ]
}

# Delta - no default routes
module "delta" {
  source       = "terraform-google-modules/network/google"
  version      = "2.3.0"
  project_id   = "f5-gcs-4138-sales-cloud-sales"
  network_name = "emes-tf-module-delta"
  subnets = [
    {
      subnet_name                            = "delta-west"
      subnet_ip                              = "172.19.0.0/16"
      subnet_region                          = "us-west1"
      delete_default_internet_gateway_routes = true
      subnet_private_access                  = true
    }
  ]
}

# Epsilon - no default routes
module "epsilon" {
  source       = "terraform-google-modules/network/google"
  version      = "2.3.0"
  project_id   = "f5-gcs-4138-sales-cloud-sales"
  network_name = "emes-tf-module-epsilon"
  subnets = [
    {
      subnet_name                            = "epsilon-west"
      subnet_ip                              = "172.20.0.0/16"
      subnet_region                          = "us-west1"
      delete_default_internet_gateway_routes = false
      subnet_private_access                  = false
    }
  ]
}

# Zeta - no default routes
module "zeta" {
  source       = "terraform-google-modules/network/google"
  version      = "2.3.0"
  project_id   = "f5-gcs-4138-sales-cloud-sales"
  network_name = "emes-tf-module-zeta"
  subnets = [
    {
      subnet_name                            = "zeta-west"
      subnet_ip                              = "172.21.0.0/16"
      subnet_region                          = "us-west1"
      delete_default_internet_gateway_routes = true
      subnet_private_access                  = true
    }
  ]
}

# Eta - no default routes
module "eta" {
  source       = "terraform-google-modules/network/google"
  version      = "2.3.0"
  project_id   = "f5-gcs-4138-sales-cloud-sales"
  network_name = "emes-tf-module-eta"
  subnets = [
    {
      subnet_name                            = "eta-west"
      subnet_ip                              = "172.22.0.0/16"
      subnet_region                          = "us-west1"
      delete_default_internet_gateway_routes = true
      subnet_private_access                  = true
    }
  ]
}

# Theta - no default routes
module "theta" {
  source       = "terraform-google-modules/network/google"
  version      = "2.3.0"
  project_id   = "f5-gcs-4138-sales-cloud-sales"
  network_name = "emes-tf-module-theta"
  subnets = [
    {
      subnet_name                            = "theta-west"
      subnet_ip                              = "172.23.0.0/16"
      subnet_region                          = "us-west1"
      delete_default_internet_gateway_routes = true
      subnet_private_access                  = true
    }
  ]
}

# Create a NAT gateway on the beta network
module "beta-nat" {
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "~> 1.3.0"
  project_id                         = "f5-gcs-4138-sales-cloud-sales"
  region                             = "us-west1"
  name                               = "emes-tf-module-beta"
  router                             = "emes-tf-module-beta"
  create_router                      = true
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  network                            = module.beta.network_self_link
  subnetworks = [
    {
      name                     = "beta-west"
      source_ip_ranges_to_nat  = ["ALL_IP_RANGES"]
      secondary_ip_range_names = []
    },
  ]
}

# Create an IAP-backed bastion
module "bastion" {
  source                     = "terraform-google-modules/bastion-host/google"
  version                    = "2.4.0"
  service_account_name       = "emes-tf-module-bastion"
  name                       = "emes-tf-module-bastion"
  name_prefix                = "emes-tf-module-bastion"
  fw_name_allow_ssh_from_iap = "emes-tf-module-allow-iap-ssh-bastion"
  project                    = "f5-gcs-4138-sales-cloud-sales"
  network                    = module.beta.network_self_link
  subnet                     = module.beta.subnets["us-west1/beta-west"].self_link
  zone                       = "us-west1-c"
  members                    = []
  # Default Bastion instance is CentOS; install tinyproxy from EPEL
  startup_script = <<EOD
#!/bin/sh
yum install -y epel-release
yum install -y tinyproxy
systemctl daemon-reload
systemctl stop tinyproxy
# Enable reverse proxy only mode and allow access from all sources; IAP is
# enforcing access to the VM.
sed -i -e '/^#\?ReverseOnly/cReverseOnly Yes' \
    -e '/^Allow /d' \
    /etc/tinyproxy/tinyproxy.conf
systemctl enable tinyproxy
systemctl start tinyproxy
EOD
}

# Allow bastion to all on beta
resource "google_compute_firewall" "bastion_beta" {
  project     = "f5-gcs-4138-sales-cloud-sales"
  name        = "emes-tf-module-allow-bastion-beta"
  network     = module.beta.network_self_link
  description = "Allow bastion to all beta ingress"
  direction   = "INGRESS"
  source_service_accounts = [
    module.bastion.service_account,
  ]
  target_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  allow {
    protocol = "all"
  }
}

# Allow SSH to all BIG-IP on alpba
resource "google_compute_firewall" "ssh_bigip_alpha" {
  project     = "f5-gcs-4138-sales-cloud-sales"
  name        = "emes-tf-module-allow-ssh-bigip-alpha"
  network     = module.alpha.network_self_link
  description = "Allow SSH to all BIG-IPs on alpha"
  direction   = "INGRESS"
  source_ranges = [
    "0.0.0.0/0",
  ]
  target_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  allow {
    protocol = "tcp"
    ports = [
      22
    ]
  }
}

# Allow CFE between BIG-IP on each network
resource "google_compute_firewall" "cfe_alpha" {
  project     = "f5-gcs-4138-sales-cloud-sales"
  name        = "emes-tf-module-allow-cfe-alpha"
  network     = module.alpha.network_self_link
  description = "CFE for alpha"
  direction   = "INGRESS"
  source_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  target_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  allow {
    protocol = "tcp"
    ports = [
      4353
    ]
  }
  allow {
    protocol = "udp"
    ports = [
      1026
    ]
  }
}
resource "google_compute_firewall" "cfe_beta" {
  project     = "f5-gcs-4138-sales-cloud-sales"
  name        = "emes-tf-module-allow-cfe-beta"
  network     = module.beta.network_self_link
  description = "CFE for beta"
  direction   = "INGRESS"
  source_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  target_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  allow {
    protocol = "tcp"
    ports = [
      4353
    ]
  }
  allow {
    protocol = "udp"
    ports = [
      1026
    ]
  }
}
resource "google_compute_firewall" "cfe_gamma" {
  project     = "f5-gcs-4138-sales-cloud-sales"
  name        = "emes-tf-module-allow-cfe-gamma"
  network     = module.gamma.network_self_link
  description = "CFE for gamma"
  direction   = "INGRESS"
  source_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  target_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  allow {
    protocol = "tcp"
    ports = [
      4353
    ]
  }
  allow {
    protocol = "udp"
    ports = [
      1026
    ]
  }
}
resource "google_compute_firewall" "cfe_delta" {
  project     = "f5-gcs-4138-sales-cloud-sales"
  name        = "emes-tf-module-allow-cfe-delta"
  network     = module.delta.network_self_link
  description = "CFE for delta"
  direction   = "INGRESS"
  source_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  target_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  allow {
    protocol = "tcp"
    ports = [
      4353
    ]
  }
  allow {
    protocol = "udp"
    ports = [
      1026
    ]
  }
}
resource "google_compute_firewall" "cfe_epsilon" {
  project     = "f5-gcs-4138-sales-cloud-sales"
  name        = "emes-tf-module-allow-cfe-epsilon"
  network     = module.epsilon.network_self_link
  description = "CFE for epsilon"
  direction   = "INGRESS"
  source_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  target_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  allow {
    protocol = "tcp"
    ports = [
      4353
    ]
  }
  allow {
    protocol = "udp"
    ports = [
      1026
    ]
  }
}
resource "google_compute_firewall" "cfe_zeta" {
  project     = "f5-gcs-4138-sales-cloud-sales"
  name        = "emes-tf-module-allow-cfe-zeta"
  network     = module.zeta.network_self_link
  description = "CFE for zeta"
  direction   = "INGRESS"
  source_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  target_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  allow {
    protocol = "tcp"
    ports = [
      4353
    ]
  }
  allow {
    protocol = "udp"
    ports = [
      1026
    ]
  }
}
resource "google_compute_firewall" "cfe_eta" {
  project     = "f5-gcs-4138-sales-cloud-sales"
  name        = "emes-tf-module-allow-cfe-eta"
  network     = module.eta.network_self_link
  description = "CFE for eta"
  direction   = "INGRESS"
  source_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  target_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  allow {
    protocol = "tcp"
    ports = [
      4353
    ]
  }
  allow {
    protocol = "udp"
    ports = [
      1026
    ]
  }
}
resource "google_compute_firewall" "cfe_theta" {
  project     = "f5-gcs-4138-sales-cloud-sales"
  name        = "emes-tf-module-allow-cfe-theta"
  network     = module.theta.network_self_link
  description = "CFE for theta"
  direction   = "INGRESS"
  source_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  target_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  allow {
    protocol = "tcp"
    ports = [
      4353
    ]
  }
  allow {
    protocol = "udp"
    ports = [
      1026
    ]
  }
}

# Create a random BIG-IP password for admin
resource "random_password" "admin_password" {
  length  = 16
  special = true
}

# Create a slot for BIG-IP admin password in Secret Manager
resource "google_secret_manager_secret" "admin_password" {
  project   = "f5-gcs-4138-sales-cloud-sales"
  secret_id = "emes-tf-module-bigip-admin-passwd-key"
  replication {
    automatic = true
  }
}

# Store the BIG-IP password in the Secret Manager
resource "google_secret_manager_secret_version" "admin_password" {
  secret      = google_secret_manager_secret.admin_password.id
  secret_data = random_password.admin_password.result
}

# Allow the supplied accounts to read the BIG-IP password from Secret Manager
resource "google_secret_manager_secret_iam_member" "admin_password" {
  for_each = toset(formatlist("serviceAccount:%s", [
    module.service_accounts.emails["bigip"],
  ]))
  project   = "f5-gcs-4138-sales-cloud-sales"
  secret_id = google_secret_manager_secret.admin_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = each.value
}
