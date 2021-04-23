# This module has been tested with Terraform 0.13+.
terraform {
  required_version = "> 0.12"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.58"
    }
  }
}

# Service account impersonation (if enabled) and Google provider setup is
# handled in providers.tf

# Generate a random prefix
resource "random_id" "prefix" {
  byte_length = 1
  prefix      = "a"
  keepers = {
    project_id = var.project_id
  }
}

# Create the service account(s) to be used in the project
module "inspec_sa" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "3.0.1"
  project_id = var.project_id
  prefix     = random_id.prefix.hex
  names      = ["inspec"]
  project_roles = [
    "${var.project_id}=>roles/compute.viewer",
    "${var.project_id}=>roles/iam.roleViewer",
  ]
  generate_keys = true
}

resource "local_file" "inspec_json" {
  content  = module.inspec_sa.key
  filename = "${path.module}/inspec-verifier.json"
}

module "bigip_sa" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "3.0.1"
  project_id = var.project_id
  prefix     = random_id.prefix.hex
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
  id         = format("%s-bigip-admin-key", random_id.prefix.hex)
  accessors = [
    # Generated service account email address is predictable - use it directly
    format("serviceAccount:%s-bigip@%s.iam.gserviceaccount.com", random_id.prefix.hex, var.project_id),
  ]
  length           = 16
  special_char_set = "@#%&*()-_=+[]<>:?"
}

# Explicitly create each VPC as this will work on all supported Terraform versions

# Alpha - allows internet egress if the instance(s) have public IPs on nic0
module "alpha" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "3.0.0"
  project_id                             = var.project_id
  network_name                           = format("%s-alpha", random_id.prefix.hex)
  delete_default_internet_gateway_routes = false
  mtu                                    = 1500
  subnets = [for region in var.regions :
    {
      subnet_name           = replace(region, "/^[^-]+/", "alpha")
      subnet_ip             = cidrsubnet("172.16.0.0/16", 8, index(var.regions, region))
      subnet_region         = region
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
  network_name                           = format("%s-beta", random_id.prefix.hex)
  delete_default_internet_gateway_routes = false
  mtu                                    = 1460
  subnets = [for region in var.regions :
    {
      subnet_name           = replace(region, "/^[^-]+/", "beta")
      subnet_ip             = cidrsubnet("172.17.0.0/16", 8, index(var.regions, region))
      subnet_region         = region
      subnet_private_access = false
    }
  ]
}

# Gamma - default routes are deleted
module "gamma" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "3.0.0"
  project_id                             = var.project_id
  network_name                           = format("%s-gamma", random_id.prefix.hex)
  delete_default_internet_gateway_routes = true
  mtu                                    = 1500
  subnets = [for region in var.regions :
    {
      subnet_name           = replace(region, "/^[^-]+/", "gamma")
      subnet_ip             = cidrsubnet("172.18.0.0/16", 8, index(var.regions, region))
      subnet_region         = region
      subnet_private_access = false
    }
  ]
}

# Delta - default routes are deleted
module "delta" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "3.0.0"
  project_id                             = var.project_id
  network_name                           = format("%s-delta", random_id.prefix.hex)
  delete_default_internet_gateway_routes = true
  mtu                                    = 1490
  subnets = [for region in var.regions :
    {
      subnet_name           = replace(region, "/^[^-]+/", "delta")
      subnet_ip             = cidrsubnet("172.19.0.0/16", 8, index(var.regions, region))
      subnet_region         = region
      subnet_private_access = false
    }
  ]
}

# Epsilon - default routes are deleted
module "epsilon" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "3.0.0"
  project_id                             = var.project_id
  network_name                           = format("%s-epsilon", random_id.prefix.hex)
  delete_default_internet_gateway_routes = true
  mtu                                    = 1480
  subnets = [for region in var.regions :
    {
      subnet_name           = replace(region, "/^[^-]+/", "epsilon")
      subnet_ip             = cidrsubnet("172.20.0.0/16", 8, index(var.regions, region))
      subnet_region         = region
      subnet_private_access = false
    }
  ]
}

# Zeta - default routes are deleted
module "zeta" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "3.0.0"
  project_id                             = var.project_id
  network_name                           = format("%s-zeta", random_id.prefix.hex)
  delete_default_internet_gateway_routes = true
  mtu                                    = 1470
  subnets = [for region in var.regions :
    {
      subnet_name           = replace(region, "/^[^-]+/", "zeta")
      subnet_ip             = cidrsubnet("172.21.0.0/16", 8, index(var.regions, region))
      subnet_region         = region
      subnet_private_access = false
    }
  ]
}

# Eta - default routes are deleted
module "eta" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "3.0.0"
  project_id                             = var.project_id
  network_name                           = format("%s-eta", random_id.prefix.hex)
  delete_default_internet_gateway_routes = true
  mtu                                    = 1460
  subnets = [for region in var.regions :
    {
      subnet_name           = replace(region, "/^[^-]+/", "eta")
      subnet_ip             = cidrsubnet("172.22.0.0/16", 8, index(var.regions, region))
      subnet_region         = region
      subnet_private_access = false
    }
  ]
}

# Theta - default routes are deleted
module "theta" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "3.0.0"
  project_id                             = var.project_id
  network_name                           = format("%s-theta", random_id.prefix.hex)
  delete_default_internet_gateway_routes = false
  mtu                                    = 1465
  subnets = [for region in var.regions :
    {
      subnet_name           = replace(region, "/^[^-]+/", "theta")
      subnet_ip             = cidrsubnet("172.23.0.0/16", 8, index(var.regions, region))
      subnet_region         = region
      subnet_private_access = false
    }
  ]
}

# Create a NAT gateway for each region on the beta network - this allows the
# BIG-IP instances to download F5 libraries, use Secret Manager, etc, on
# management interface which is the only interface configured until DO is applied.
module "beta-nat" {
  for_each                           = toset(var.regions)
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "~> 1.3.0"
  project_id                         = var.project_id
  region                             = each.value
  name                               = format("%s-%s", random_id.prefix.hex, replace(each.value, "/^[^-]+/", "beta"))
  router                             = format("%s-%s", random_id.prefix.hex, replace(each.value, "/^[^-]+/", "beta"))
  create_router                      = true
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  network                            = module.beta.network_self_link
}

resource "google_compute_firewall" "admin_alpha" {
  project                 = var.project_id
  name                    = format("%s-alpha-allow-admin-access", random_id.prefix.hex)
  network                 = module.alpha.network_self_link
  description             = format("Allow external admin access on alpha (%s)", random_id.prefix.hex)
  direction               = "INGRESS"
  source_ranges           = var.admin_source_cidrs
  target_service_accounts = module.bigip_sa.emails_list
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
  name                    = format("%s-beta-allow-admin-access", random_id.prefix.hex)
  network                 = module.beta.network_self_link
  description             = format("Allow external admin access on beta (%s)", random_id.prefix.hex)
  direction               = "INGRESS"
  source_ranges           = var.admin_source_cidrs
  target_service_accounts = module.bigip_sa.emails_list
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

# Write the harness.tfvars to pass into test fixtures
resource "local_file" "harness_tfvars" {
  filename = "${path.module}/harness.tfvars"
  content  = <<EOC
tf_sa_email = "${var.tf_sa_email}"
project_id = "${var.project_id}"
prefix = "${random_id.prefix.hex}"
service_account = "${module.bigip_sa.email}"
admin_password_secret_manager_key = "${module.password.secret_id}"
alpha_net = "${module.alpha.network_self_link}"
alpha_subnets = ${jsonencode({ for k, v in module.alpha.subnets : v.region => v.self_link })}
beta_net = "${module.beta.network_self_link}"
beta_subnets = ${jsonencode({ for k, v in module.beta.subnets : v.region => v.self_link })}
gamma_net = "${module.gamma.network_self_link}"
gamma_subnets = ${jsonencode({ for k, v in module.gamma.subnets : v.region => v.self_link })}
delta_net = "${module.delta.network_self_link}"
delta_subnets = ${jsonencode({ for k, v in module.delta.subnets : v.region => v.self_link })}
epsilon_net = "${module.epsilon.network_self_link}"
epsilon_subnets = ${jsonencode({ for k, v in module.epsilon.subnets : v.region => v.self_link })}
zeta_net = "${module.zeta.network_self_link}"
zeta_subnets = ${jsonencode({ for k, v in module.zeta.subnets : v.region => v.self_link })}
eta_net = "${module.eta.network_self_link}"
eta_subnets = ${jsonencode({ for k, v in module.eta.subnets : v.region => v.self_link })}
theta_net = "${module.theta.network_self_link}"
theta_subnets = ${jsonencode({ for k, v in module.theta.subnets : v.region => v.self_link })}
EOC
}
