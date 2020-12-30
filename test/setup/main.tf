# This module has been tested with Terraform 0.12, 0.13 and 0.14.
terraform {
  required_version = "> 0.11"
}

# Service account impersonation (if enabled) and Google provider setup is
# handled in providers.tf

# Generate a random prefix
resource "random_pet" "prefix" {
  keepers = {
    project_id = var.project_id
  }
}

# Create the service account(s) to be used in the project
module "sa" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "3.0.1"
  project_id = var.project_id
  prefix     = random_pet.prefix.id
  names      = ["bigip"]
  project_roles = [
    "${var.project_id}=>roles/logging.logWriter",
    "${var.project_id}=>roles/monitoring.metricWriter",
    "${var.project_id}=>roles/monitoring.viewer",
  ]
  generate_keys = false
}

module "password" {
  source     = "memes/secret-manager/google//modules/random"
  version    = "1.0.2"
  project_id = var.project_id
  id         = format("%s-bigip-admin-key", random_pet.prefix.id)
  accessors = [
    # Generated service account email address is predictable - use it directly
    format("serviceAccount:%s-bigip@%s.iam.gserviceaccount.com", random_pet.prefix.id, var.project_id),
  ]
  length           = 16
  special_char_set = "@#%&*()-_=+[]<>:?"
}

locals {
  short_region = replace(var.region, "/^[^-]+-([^0-9-]+)[0-9]$/", "$1")
}

# Explicitly create each VPC as this will work on all supported Terraform versions

# Alpha - allows internet egress if the instance(s) have public IPs on nic0
module "alpha" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "3.0.0"
  project_id                             = var.project_id
  network_name                           = format("%s-alpha", random_pet.prefix.id)
  delete_default_internet_gateway_routes = false
  mtu                                    = 1500
  subnets = [
    {
      subnet_name           = format("alpha-%s", local.short_region)
      subnet_ip             = "172.16.0.0/16"
      subnet_region         = var.region
      subnet_private_access = false
    }
  ]
}

# Beta - a NAT gateway will be provisioned to support egress for control-plane
# download and installation of libraries, reaching Google APIs, etc.
module "beta" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "3.0.0"
  project_id                             = var.project_id
  network_name                           = format("%s-beta", random_pet.prefix.id)
  delete_default_internet_gateway_routes = false
  mtu                                    = 1460
  subnets = [
    {
      subnet_name           = format("beta-%s", local.short_region)
      subnet_ip             = "172.17.0.0/16"
      subnet_region         = var.region
      subnet_private_access = false
    }
  ]
}

# Gamma - default routes are deleted
module "gamma" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "3.0.0"
  project_id                             = var.project_id
  network_name                           = format("%s-gamma", random_pet.prefix.id)
  delete_default_internet_gateway_routes = true
  mtu                                    = 1500
  subnets = [
    {
      subnet_name           = format("gamma-%s", local.short_region)
      subnet_ip             = "172.18.0.0/16"
      subnet_region         = var.region
      subnet_private_access = false
    }
  ]
}

# Delta - default routes are deleted
module "delta" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "3.0.0"
  project_id                             = var.project_id
  network_name                           = format("%s-delta", random_pet.prefix.id)
  delete_default_internet_gateway_routes = true
  mtu                                    = 1490
  subnets = [
    {
      subnet_name           = format("delta-%s", local.short_region)
      subnet_ip             = "172.19.0.0/16"
      subnet_region         = var.region
      subnet_private_access = false
    }
  ]
}

# Epsilon - default routes are deleted
module "epsilon" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "3.0.0"
  project_id                             = var.project_id
  network_name                           = format("%s-epsilon", random_pet.prefix.id)
  delete_default_internet_gateway_routes = true
  mtu                                    = 1480
  subnets = [
    {
      subnet_name           = format("epsilon-%s", local.short_region)
      subnet_ip             = "172.20.0.0/16"
      subnet_region         = var.region
      subnet_private_access = false
    }
  ]
}

# Zeta - default routes are deleted
module "zeta" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "3.0.0"
  project_id                             = var.project_id
  network_name                           = format("%s-zeta", random_pet.prefix.id)
  delete_default_internet_gateway_routes = true
  mtu                                    = 1470
  subnets = [
    {
      subnet_name           = format("zeta-%s", local.short_region)
      subnet_ip             = "172.21.0.0/16"
      subnet_region         = var.region
      subnet_private_access = false
    }
  ]
}

# Eta - default routes are deleted
module "eta" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "3.0.0"
  project_id                             = var.project_id
  network_name                           = format("%s-eta", random_pet.prefix.id)
  delete_default_internet_gateway_routes = true
  mtu                                    = 1460
  subnets = [
    {
      subnet_name           = format("eta-%s", local.short_region)
      subnet_ip             = "172.22.0.0/16"
      subnet_region         = var.region
      subnet_private_access = false
    }
  ]
}

# Theta - default routes are deleted
module "theta" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "3.0.0"
  project_id                             = var.project_id
  network_name                           = format("%s-theta", random_pet.prefix.id)
  delete_default_internet_gateway_routes = false
  mtu                                    = 1465
  subnets = [
    {
      subnet_name           = format("theta-%s", local.short_region)
      subnet_ip             = "172.23.0.0/16"
      subnet_region         = var.region
      subnet_private_access = false
    }
  ]
}

# Create a NAT gateway on the beta network - this allows the BIG-IP instances
# to download F5 libraries, use Secret Manager, etc, on management interface
# which is the only interface configured until DO is applied.
module "beta-nat" {
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "~> 1.3.0"
  project_id                         = var.project_id
  region                             = var.region
  name                               = format("%s-beta", random_pet.prefix.id)
  router                             = format("%s-beta", random_pet.prefix.id)
  create_router                      = true
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  network                            = module.beta.network_self_link
  subnetworks = [
    {
      name                     = element(module.beta.subnets_self_links, 0)
      source_ip_ranges_to_nat  = ["ALL_IP_RANGES"]
      secondary_ip_range_names = []
    },
  ]
}

resource "google_compute_firewall" "admin_alpha" {
  project                 = var.project_id
  name                    = format("%s-alpha-allow-admin-access", random_pet.prefix.id)
  network                 = module.alpha.network_self_link
  description             = format("Allow external admin access on alpha (%s)", random_pet.prefix.id)
  direction               = "INGRESS"
  source_ranges           = var.admin_source_cidrs
  target_service_accounts = [module.sa.emails["bigip"]]
  allow {
    protocol = "tcp"
    ports = [
      22,
      8443,
    ]
  }
  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "admin_beta" {
  project                 = var.project_id
  name                    = format("%s-beta-allow-admin-access", random_pet.prefix.id)
  network                 = module.beta.network_self_link
  description             = format("Allow external admin access on beta (%s)", random_pet.prefix.id)
  direction               = "INGRESS"
  source_ranges           = var.admin_source_cidrs
  target_service_accounts = [module.sa.emails["bigip"]]
  allow {
    protocol = "tcp"
    ports = [
      22,
      443,
    ]
  }
  allow {
    protocol = "icmp"
  }
}
