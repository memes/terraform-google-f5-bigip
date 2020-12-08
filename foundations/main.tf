# This module has been tested with Terraform 0.12, 0.13 and 0.14.
terraform {
  required_version = "> 0.11"
  # Backend variables bucket and prefix must be set in a config file during
  # `terraform init`.
  backend "gcs" {}
}

# Service account impersonation (if enabled) and Google provider setup is
# handled in providers.tf

locals {
  bastion_zone = format("%s-a", var.region)
  short_region = replace(var.region, "/^[^-]+-([^0-9-]+)[0-9]$/", "$1")
}

# Create the service account(s) to be used in the project
module "service_accounts" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "3.0.1"
  project_id = var.project_id
  prefix     = var.prefix
  names      = ["bigip", "backend"]
  project_roles = [
    "${var.project_id}=>roles/logging.logWriter",
    "${var.project_id}=>roles/monitoring.metricWriter",
    "${var.project_id}=>roles/monitoring.viewer",
    # This is to support BIG-IP downstream service discovery
    "${var.project_id}=>roles/compute.viewer"
  ]
  generate_keys = false
}

# Create 8 networks for module testing

# Alpha - allows internet egress if the instance(s) have public IPs or via NAT
module "alpha" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "2.5.0"
  project_id                             = var.project_id
  network_name                           = format("%s-alpha", var.prefix)
  delete_default_internet_gateway_routes = false
  subnets = [
    {
      subnet_name           = format("alpha-%s", local.short_region)
      subnet_ip             = var.alpha_cidr
      subnet_region         = var.region
      subnet_private_access = false
    }
  ]
}

# Beta - a NAT gateway will be provisioned to support egress
module "beta" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "2.5.0"
  project_id                             = var.project_id
  network_name                           = format("%s-beta", var.prefix)
  delete_default_internet_gateway_routes = false
  subnets = [
    {
      subnet_name           = format("beta-%s", local.short_region)
      subnet_ip             = var.beta_cidr
      subnet_region         = var.region
      subnet_private_access = false
    }
  ]
}

# Gamma - no default routes
module "gamma" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "2.5.0"
  project_id                             = var.project_id
  network_name                           = format("%s-gamma", var.prefix)
  delete_default_internet_gateway_routes = true
  subnets = [
    {
      subnet_name           = format("gamma-%s", local.short_region)
      subnet_ip             = var.gamma_cidr
      subnet_region         = var.region
      subnet_private_access = true
    }
  ]
  routes = [
    {
      name              = format("%s-restricted-apis-gamma", var.prefix)
      description       = "Restricted API route emes-tf-module on gamma"
      destination_range = "199.36.153.4/30"
      next_hop_internet = true
    }
  ]
}

# Delta - no default routes
module "delta" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "2.5.0"
  project_id                             = var.project_id
  network_name                           = format("%s-delta", var.prefix)
  delete_default_internet_gateway_routes = true
  subnets = [
    {
      subnet_name           = format("delta-%s", local.short_region)
      subnet_ip             = var.delta_cidr
      subnet_region         = var.region
      subnet_private_access = true
    }
  ]
  routes = [
    {
      name              = format("%s-restricted-apis-delta", var.prefix)
      description       = "Restricted API route emes-tf-module on delta"
      destination_range = "199.36.153.4/30"
      next_hop_internet = true
    }
  ]
}

# Epsilon - no default routes
module "epsilon" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "2.5.0"
  project_id                             = var.project_id
  network_name                           = format("%s-epsilon", var.prefix)
  delete_default_internet_gateway_routes = true
  subnets = [
    {
      subnet_name           = format("epsilon-%s", local.short_region)
      subnet_ip             = var.epsilon_cidr
      subnet_region         = var.region
      subnet_private_access = false
    }
  ]
  routes = [
    {
      name              = format("%s-restricted-apis-epsilon", var.prefix)
      description       = "Restricted API route emes-tf-module on epsilon"
      destination_range = "199.36.153.4/30"
      next_hop_internet = true
    }
  ]
}

# Zeta - no default routes
module "zeta" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "2.5.0"
  project_id                             = var.project_id
  network_name                           = format("%s-zeta", var.prefix)
  delete_default_internet_gateway_routes = true
  subnets = [
    {
      subnet_name           = format("zeta-%s", local.short_region)
      subnet_ip             = var.zeta_cidr
      subnet_region         = var.region
      subnet_private_access = true
    }
  ]
  routes = [
    {
      name              = format("%s-restricted-apis-zeta", var.prefix)
      description       = "Restricted API route emes-tf-module on zeta"
      destination_range = "199.36.153.4/30"
      next_hop_internet = true
    }
  ]
}

# Eta - no default routes
module "eta" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "2.5.0"
  project_id                             = var.project_id
  network_name                           = format("%s-eta", var.prefix)
  delete_default_internet_gateway_routes = true
  subnets = [
    {
      subnet_name           = format("eta-%s", local.short_region)
      subnet_ip             = var.eta_cidr
      subnet_region         = var.region
      subnet_private_access = true
    }
  ]
  routes = [
    {
      name              = format("%s-restricted-apis-eta", var.prefix)
      description       = "Restricted API route emes-tf-module on eta"
      destination_range = "199.36.153.4/30"
      next_hop_internet = true
    }
  ]
}

# Theta - no default routes
module "theta" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "2.5.0"
  project_id                             = var.project_id
  network_name                           = format("%s-theta", var.prefix)
  delete_default_internet_gateway_routes = true
  subnets = [
    {
      subnet_name           = format("theta-%s", local.short_region)
      subnet_ip             = var.theta_cidr
      subnet_region         = var.region
      subnet_private_access = true
    }
  ]
  routes = [
    {
      name              = format("%s-restricted-apis-theta", var.prefix)
      description       = "Restricted API route emes-tf-module on theta"
      destination_range = "199.36.153.4/30"
      next_hop_internet = true
    }
  ]
}

# Create a NAT gateway on the alpha network
module "alpha-nat" {
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "~> 1.3.0"
  project_id                         = var.project_id
  region                             = var.region
  name                               = format("%s-alpha", var.prefix)
  router                             = format("%s-alpha", var.prefix)
  create_router                      = true
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  network                            = module.alpha.network_self_link
  subnetworks = [
    {
      name                     = format("alpha-%s", local.short_region)
      source_ip_ranges_to_nat  = ["ALL_IP_RANGES"]
      secondary_ip_range_names = []
    },
  ]
}

# Create a NAT gateway on the beta network
module "beta-nat" {
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "~> 1.3.0"
  project_id                         = var.project_id
  region                             = var.region
  name                               = format("%s-beta", var.prefix)
  router                             = format("%s-beta", var.prefix)
  create_router                      = true
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  network                            = module.beta.network_self_link
  subnetworks = [
    {
      name                     = format("beta-%s", local.short_region)
      source_ip_ranges_to_nat  = ["ALL_IP_RANGES"]
      secondary_ip_range_names = []
    },
  ]
}

# Create an IAP-backed bastion
module "bastion" {
  source                     = "terraform-google-modules/bastion-host/google"
  version                    = "2.10.0"
  service_account_name       = format("%s-bastion", var.prefix)
  name                       = format("%s-bastion", var.prefix)
  name_prefix                = format("%s-bastion", var.prefix)
  fw_name_allow_ssh_from_iap = format("%s-allow-iap-ssh-bastion", var.prefix)
  project                    = var.project_id
  network                    = module.beta.network_self_link
  subnet                     = module.beta.subnets[format("us-west1/beta-%s", local.short_region)].self_link
  zone                       = local.bastion_zone
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
  project     = var.project_id
  name        = format("%s-allow-bastion-beta", var.prefix)
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
resource "google_compute_firewall" "public_bigip_alpha" {
  project     = var.project_id
  name        = format("%s-allow-ssh-bigip-alpha", var.prefix)
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
      "22",
      "80",
      "443",
      "8443",
    ]
  }
}

# Allow configsync between BIG-IPs on alpba
resource "google_compute_firewall" "sync_alpha" {
  project     = var.project_id
  name        = format("%s-allow-sync-alpha", var.prefix)
  network     = module.alpha.network_self_link
  description = "ConfigSync for alpha"
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
      "443",
      "4353",
      "6123-6128",
    ]
  }
  allow {
    protocol = "udp"
    ports = [
      "1026",
    ]
  }
}

# Allow configsync between BIG-IPs on beta
resource "google_compute_firewall" "beta" {
  project     = var.project_id
  name        = format("%s-allow-sync-beta", var.prefix)
  network     = module.beta.network_self_link
  description = "ConfigSync for beta"
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
      "443",
    ]
  }
}

# Allow configsync between BIG-IPs on gamma
resource "google_compute_firewall" "sync_gamma" {
  project     = var.project_id
  name        = format("%s-allow-sync-gamma", var.prefix)
  network     = module.gamma.network_self_link
  description = "ConfigSync for gamma"
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
      "443",
      "4353",
      "6123-6128",
    ]
  }
  allow {
    protocol = "udp"
    ports = [
      "1026",
    ]
  }
}

# Allow configsync between BIG-IPs on delta
resource "google_compute_firewall" "sync_delta" {
  project     = var.project_id
  name        = format("%s-allow-sync-delta", var.prefix)
  network     = module.delta.network_self_link
  description = "ConfigSync for delta"
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
      "443",
      "4353",
      "6123-6128",
    ]
  }
  allow {
    protocol = "udp"
    ports = [
      "1026",
    ]
  }
}

# Allow configsync between BIG-IPs on epsilon
resource "google_compute_firewall" "sync_epsilon" {
  project     = var.project_id
  name        = format("%s-allow-sync-epsilon", var.prefix)
  network     = module.epsilon.network_self_link
  description = "ConfigSync for epsilon"
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
      "443",
      "4353",
      "6123-6128",
    ]
  }
  allow {
    protocol = "udp"
    ports = [
      "1026",
    ]
  }
}

# Allow configsync between BIG-IPs on zeta
resource "google_compute_firewall" "sync_zeta" {
  project     = var.project_id
  name        = format("%s-allow-sync-zeta", var.prefix)
  network     = module.zeta.network_self_link
  description = "ConfigSync for zeta"
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
      "443",
      "4353",
      "6123-6128",
    ]
  }
  allow {
    protocol = "udp"
    ports = [
      "1026",
    ]
  }
}

# Allow configsync between BIG-IPs on eta
resource "google_compute_firewall" "sync_eta" {
  project     = var.project_id
  name        = format("%s-allow-sync-eta", var.prefix)
  network     = module.eta.network_self_link
  description = "ConfigSync for eta"
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
      "443",
      "4353",
      "6123-6128",
    ]
  }
  allow {
    protocol = "udp"
    ports = [
      "1026",
    ]
  }
}

# Allow configsync between BIG-IPs on alpba
resource "google_compute_firewall" "sync_theta" {
  project     = var.project_id
  name        = format("%s-allow-sync-theta", var.prefix)
  network     = module.theta.network_self_link
  description = "ConfigSync for theta"
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
      "443",
      "4353",
      "6123-6128",
    ]
  }
  allow {
    protocol = "udp"
    ports = [
      "1026",
    ]
  }
}

module "bigip_password" {
  source     = "memes/secret-manager/google//modules/random"
  version    = "1.0.2"
  project_id = var.project_id
  id         = format("%s-bigip-admin-passwd-key", var.prefix)
  accessors = [
    "serviceAccount:emes-tf-module-bigip@f5-gcs-4138-sales-cloud-sales.iam.gserviceaccount.com"
  ]
  length           = 16
  special_char_set = "@#%&*()-_=+[]<>:?"
}

# Allow GCP health checks to BIG-IPs on alpba
resource "google_compute_firewall" "hc_alpha" {
  project     = var.project_id
  name        = format("%s-allow-hc-alpha", var.prefix)
  network     = module.alpha.network_self_link
  description = "Blanket health check support on alpha"
  direction   = "INGRESS"
  source_ranges = [
    # Common to all
    "35.191.0.0/16",
    # Non-NLB health checks
    "130.211.0.0/22",
    # NLB specific
    "209.85.152.0/22",
    "209.85.204.0/22"
  ]
  target_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  # Allow on all ports
  allow {
    protocol = "tcp"
  }
}

# Allow GCP health checks to all on gamma
resource "google_compute_firewall" "hc_gamma" {
  project     = var.project_id
  name        = format("%s-allow-hc-gamma", var.prefix)
  network     = module.gamma.network_self_link
  description = "Blanket health check support on gamma"
  direction   = "INGRESS"
  source_ranges = [
    # Common to all
    "35.191.0.0/16",
    # Non-NLB health checks
    "130.211.0.0/22",
    # NLB specific
    "209.85.152.0/22",
    "209.85.204.0/22"
  ]
  # Allow on all ports
  allow {
    protocol = "tcp"
  }
}

# Allow BIG-IPs to all on gamma
resource "google_compute_firewall" "bigip_gamma" {
  project     = var.project_id
  name        = format("%s-allow-bigip-gamma", var.prefix)
  network     = module.gamma.network_self_link
  description = "Allow BIG-IP to gamma services"
  direction   = "INGRESS"
  source_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
}

# Allow BIG-IPs to all on delta
resource "google_compute_firewall" "bigip_delta" {
  project     = var.project_id
  name        = format("%s-allow-bigip-delta", var.prefix)
  network     = module.delta.network_self_link
  description = "Allow BIG-IP to delta services"
  direction   = "INGRESS"
  source_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
}

# Allow BIG-IPs to all on epsilon
resource "google_compute_firewall" "bigip_epsilon" {
  project     = var.project_id
  name        = format("%s-allow-bigip-epsilon", var.prefix)
  network     = module.epsilon.network_self_link
  description = "Allow BIG-IP to epsilon services"
  direction   = "INGRESS"
  source_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
}

# Allow BIG-IPs to all on zeta
resource "google_compute_firewall" "bigip_zeta" {
  project     = var.project_id
  name        = format("%s-allow-bigip-zeta", var.prefix)
  network     = module.zeta.network_self_link
  description = "Allow BIG-IP to zeta services"
  direction   = "INGRESS"
  source_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
}

# Allow BIG-IPs to all on eta
resource "google_compute_firewall" "bigip_eta" {
  project     = var.project_id
  name        = format("%s-allow-bigip-eta", var.prefix)
  network     = module.eta.network_self_link
  description = "Allow BIG-IP to eta services"
  direction   = "INGRESS"
  source_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
}

# Allow BIG-IPs to all on theta
resource "google_compute_firewall" "bigip_theta" {
  project     = var.project_id
  name        = format("%s-allow-bigip-theta", var.prefix)
  network     = module.theta.network_self_link
  description = "Allow BIG-IP to theta services"
  direction   = "INGRESS"
  source_service_accounts = [
    module.service_accounts.emails["bigip"],
  ]
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
}

# Setup a private Cloud DNS zone to override googleapis.com with
# restricted.googleapis.com.
module "googleapis" {
  source      = "terraform-google-modules/cloud-dns/google"
  version     = "3.0.2"
  project_id  = var.project_id
  type        = "private"
  name        = format("%s-restricted-googleapis-com", var.prefix)
  domain      = "googleapis.com."
  description = format("Override googleapis.com domain to use restricted.googleapis.com (%s)", var.prefix)
  # Apply to all six networks behind BIG-IPs
  private_visibility_config_networks = [
    module.gamma.network_self_link,
    module.delta.network_self_link,
    module.epsilon.network_self_link,
    module.zeta.network_self_link,
    module.eta.network_self_link,
    module.theta.network_self_link,
  ]
  recordsets = [
    {
      name = "*"
      type = "CNAME"
      ttl  = 300
      records = [
        "restricted.googleapis.com.",
      ]
    },
    {
      name = "restricted"
      type = "A"
      ttl  = 300
      records = [
        "199.36.153.4",
        "199.36.153.5",
        "199.36.153.6",
        "199.36.153.7",
      ]
    }
  ]
}
