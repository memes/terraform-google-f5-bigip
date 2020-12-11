# This module has been tested with Terraform 0.12, 0.13 and 0.14.
terraform {
  required_version = "> 0.11"
}

# Service account impersonation (if enabled) and Google provider setup is
# handled in providers.tf

# Create the service account(s) to be used in the project
module "sa" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "3.0.1"
  project_id = var.project_id
  prefix     = var.prefix
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
  id         = format("%s-bigip-admin-key", var.prefix)
  accessors = [
    # Generated service account email address is predictable - use it directly
    format("serviceAccount:%s-bigip@%s.iam.gserviceaccount.com", var.prefix, var.project_id),
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
  /* TODO: @memes - update when Google publishes my PR
  source                                 = "terraform-google-modules/network/google"
  version                                = "2.6.0"
  */
  source                                 = "git::https://github.com/terraform-google-modules/terraform-google-network?ref=bb31529"
  project_id                             = var.project_id
  network_name                           = format("%s-alpha", var.prefix)
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
  /* TODO: @memes - update when Google publishes my PR
  source                                 = "terraform-google-modules/network/google"
  version                                = "2.5.0"
  */
  source                                 = "git::https://github.com/terraform-google-modules/terraform-google-network?ref=bb31529"
  project_id                             = var.project_id
  network_name                           = format("%s-beta", var.prefix)
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
  /* TODO: @memes - update when Google publishes my PR
  source                                 = "terraform-google-modules/network/google"
  version                                = "2.5.0"
  */
  source                                 = "git::https://github.com/terraform-google-modules/terraform-google-network?ref=bb31529"
  project_id                             = var.project_id
  network_name                           = format("%s-gamma", var.prefix)
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
  /* TODO: @memes - update when Google publishes my PR
  source                                 = "terraform-google-modules/network/google"
  version                                = "2.5.0"
  */
  source                                 = "git::https://github.com/terraform-google-modules/terraform-google-network?ref=bb31529"
  project_id                             = var.project_id
  network_name                           = format("%s-delta", var.prefix)
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
  /* TODO: @memes - update when Google publishes my PR
  source                                 = "terraform-google-modules/network/google"
  version                                = "2.5.0"
  */
  source                                 = "git::https://github.com/terraform-google-modules/terraform-google-network?ref=bb31529"
  project_id                             = var.project_id
  network_name                           = format("%s-epsilon", var.prefix)
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
  /* TODO: @memes - update when Google publishes my PR
  source                                 = "terraform-google-modules/network/google"
  version                                = "2.5.0"
  */
  source                                 = "git::https://github.com/terraform-google-modules/terraform-google-network?ref=bb31529"
  project_id                             = var.project_id
  network_name                           = format("%s-zeta", var.prefix)
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
  /* TODO: @memes - update when Google publishes my PR
  source                                 = "terraform-google-modules/network/google"
  version                                = "2.5.0"
  */
  source                                 = "git::https://github.com/terraform-google-modules/terraform-google-network?ref=bb31529"
  project_id                             = var.project_id
  network_name                           = format("%s-eta", var.prefix)
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
  /* TODO: @memes - update when Google publishes my PR
  source                                 = "terraform-google-modules/network/google"
  version                                = "2.5.0"
  */
  source                                 = "git::https://github.com/terraform-google-modules/terraform-google-network?ref=bb31529"
  project_id                             = var.project_id
  network_name                           = format("%s-theta", var.prefix)
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
  name                               = format("%s-beta", var.prefix)
  router                             = format("%s-beta", var.prefix)
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
