# This file reserves private and public IP addresses

# Always need reservations on alpha
resource "google_compute_address" "alpha_private" {
  count        = var.reserve_addresses ? var.num_instances : 0
  project      = var.project_id
  name         = format(format("%s-%s-alpha-priv", var.prefix, var.instance_name_template), count.index + var.instance_ordinal_offset)
  subnetwork   = var.alpha_subnet
  address_type = "INTERNAL"
  region       = var.region
}

resource "google_compute_address" "alpha_public" {
  count        = var.reserve_addresses && var.provision_external_public_ip ? var.num_instances : 0
  project      = var.project_id
  name         = format(format("%s-%s-alpha-pub", var.prefix, var.instance_name_template), count.index + var.instance_ordinal_offset)
  address_type = "EXTERNAL"
  region       = var.region
  network_tier = var.external_subnetwork_tier
}

# Beta network reservations if nics > 1
resource "google_compute_address" "beta_private" {
  count        = var.reserve_addresses && var.num_nics > 1 ? var.num_instances : 0
  project      = var.project_id
  name         = format(format("%s-%s-beta-priv", var.prefix, var.instance_name_template), count.index + var.instance_ordinal_offset)
  subnetwork   = var.beta_subnet
  address_type = "INTERNAL"
  region       = var.region
}

resource "google_compute_address" "beta_public" {
  count        = var.reserve_addresses && var.provision_management_public_ip && var.num_nics > 1 ? var.num_instances : 0
  project      = var.project_id
  name         = format(format("%s-%s-beta-pub", var.prefix, var.instance_name_template), count.index + var.instance_ordinal_offset)
  address_type = "EXTERNAL"
  region       = var.region
  network_tier = var.management_subnetwork_tier
}

# Gamma network reservation if num_nics > 2
resource "google_compute_address" "gamma_private" {
  count        = var.reserve_addresses && var.num_nics > 2 ? var.num_instances : 0
  project      = var.project_id
  name         = format(format("%s-%s-gamma-priv", var.prefix, var.instance_name_template), count.index + var.instance_ordinal_offset)
  subnetwork   = var.gamma_subnet
  address_type = "INTERNAL"
  region       = var.region
}

resource "google_compute_address" "gamma_public" {
  count        = var.reserve_addresses && var.provision_internal_public_ip && var.num_nics > 2 ? var.num_instances : 0
  project      = var.project_id
  name         = format(format("%s-%s-gamma-pub", var.prefix, var.instance_name_template), count.index + var.instance_ordinal_offset)
  address_type = "EXTERNAL"
  region       = var.region
  network_tier = var.internal_subnetwork_tier
}

# Delta reservations if nics > 3
resource "google_compute_address" "delta_private" {
  count        = var.reserve_addresses && var.num_nics > 3 ? var.num_instances : 0
  project      = var.project_id
  name         = format(format("%s-%s-delta-priv", var.prefix, var.instance_name_template), count.index + var.instance_ordinal_offset)
  subnetwork   = var.delta_subnet
  address_type = "INTERNAL"
  region       = var.region
}

resource "google_compute_address" "delta_public" {
  count        = var.reserve_addresses && var.provision_internal_public_ip && var.num_nics > 3 ? var.num_instances : 0
  project      = var.project_id
  name         = format(format("%s-%s-delta-pub", var.prefix, var.instance_name_template), count.index + var.instance_ordinal_offset)
  address_type = "EXTERNAL"
  region       = var.region
  network_tier = var.internal_subnetwork_tier
}

# Epsilon reservations if nics > 4
resource "google_compute_address" "epsilon_private" {
  count        = var.reserve_addresses && var.num_nics > 4 ? var.num_instances : 0
  project      = var.project_id
  name         = format(format("%s-%s-epsilon-priv", var.prefix, var.instance_name_template), count.index + var.instance_ordinal_offset)
  subnetwork   = var.epsilon_subnet
  address_type = "INTERNAL"
  region       = var.region
}

resource "google_compute_address" "epsilon_public" {
  count        = var.reserve_addresses && var.provision_internal_public_ip && var.num_nics > 4 ? var.num_instances : 0
  project      = var.project_id
  name         = format(format("%s-%s-epsilon-pub", var.prefix, var.instance_name_template), count.index + var.instance_ordinal_offset)
  address_type = "EXTERNAL"
  region       = var.region
  network_tier = var.internal_subnetwork_tier
}

# Zeta reservations if nics > 5
resource "google_compute_address" "zeta_private" {
  count        = var.reserve_addresses && var.num_nics > 5 ? var.num_instances : 0
  project      = var.project_id
  name         = format(format("%s-%s-zeta-priv", var.prefix, var.instance_name_template), count.index + var.instance_ordinal_offset)
  subnetwork   = var.zeta_subnet
  address_type = "INTERNAL"
  region       = var.region
}

resource "google_compute_address" "zeta_public" {
  count        = var.reserve_addresses && var.provision_internal_public_ip && var.num_nics > 5 ? var.num_instances : 0
  project      = var.project_id
  name         = format(format("%s-%s-zeta-pub", var.prefix, var.instance_name_template), count.index + var.instance_ordinal_offset)
  address_type = "EXTERNAL"
  region       = var.region
  network_tier = var.internal_subnetwork_tier
}

# Eta reservations if nics > 6
resource "google_compute_address" "eta_private" {
  count        = var.reserve_addresses && var.num_nics > 6 ? var.num_instances : 0
  project      = var.project_id
  name         = format(format("%s-%s-eta-priv", var.prefix, var.instance_name_template), count.index + var.instance_ordinal_offset)
  subnetwork   = var.eta_subnet
  address_type = "INTERNAL"
  region       = var.region
}

resource "google_compute_address" "eta_public" {
  count        = var.reserve_addresses && var.provision_internal_public_ip && var.num_nics > 6 ? var.num_instances : 0
  project      = var.project_id
  name         = format(format("%s-%s-eta-pub", var.prefix, var.instance_name_template), count.index + var.instance_ordinal_offset)
  address_type = "EXTERNAL"
  region       = var.region
  network_tier = var.internal_subnetwork_tier
}

# Theta reservations if nics > 7
resource "google_compute_address" "theta_private" {
  count        = var.reserve_addresses && var.num_nics > 7 ? var.num_instances : 0
  project      = var.project_id
  name         = format(format("%s-%s-theta-priv", var.prefix, var.instance_name_template), count.index + var.instance_ordinal_offset)
  subnetwork   = var.theta_subnet
  address_type = "INTERNAL"
  region       = var.region
}

resource "google_compute_address" "theta_public" {
  count        = var.reserve_addresses && var.provision_internal_public_ip && var.num_nics > 7 ? var.num_instances : 0
  project      = var.project_id
  name         = format(format("%s-%s-theta-pub", var.prefix, var.instance_name_template), count.index + var.instance_ordinal_offset)
  address_type = "EXTERNAL"
  region       = var.region
  network_tier = var.internal_subnetwork_tier
}

# For convenience, map the generated addresses to the names and forms expected
# by root module
locals {
  external_subnetwork_network_ips   = [for r in google_compute_address.alpha_private : r.address]
  external_subnetwork_vip_cidrs     = []
  external_subnetwork_public_ips    = [for r in google_compute_address.alpha_public : r.address]
  management_subnetwork_network_ips = [for r in google_compute_address.beta_private : r.address]
  management_subnetwork_vip_cidrs   = []
  management_subnetwork_public_ips  = [for r in google_compute_address.beta_public : r.address]
  internal_subnetwork_network_ips = [for i in range(0, var.num_instances) : compact([
    length(google_compute_address.gamma_private) > 0 ? element(coalescelist(google_compute_address.gamma_private, [""]), i).address : "",
    length(google_compute_address.delta_private) > 0 ? element(coalescelist(google_compute_address.delta_private, [""]), i).address : "",
    length(google_compute_address.epsilon_private) > 0 ? element(coalescelist(google_compute_address.epsilon_private, [""]), i).address : "",
    length(google_compute_address.zeta_private) > 0 ? element(coalescelist(google_compute_address.zeta_private, [""]), i).address : "",
    length(google_compute_address.eta_private) > 0 ? element(coalescelist(google_compute_address.eta_private, [""]), i).address : "",
    length(google_compute_address.theta_private) > 0 ? element(coalescelist(google_compute_address.theta_private, [""]), i).address : "",
    ])
  ]
  internal_subnetwork_vip_cidrs = []
  internal_subnetwork_public_ips = [for i in range(0, var.num_instances) : compact(
    [
      length(google_compute_address.gamma_public) > 0 ? element(coalescelist(google_compute_address.gamma_public, [""]), i).address : "",
      length(google_compute_address.delta_public) > 0 ? element(coalescelist(google_compute_address.delta_public, [""]), i).address : "",
      length(google_compute_address.epsilon_public) > 0 ? element(coalescelist(google_compute_address.epsilon_public, [""]), i).address : "",
      length(google_compute_address.zeta_public) > 0 ? element(coalescelist(google_compute_address.zeta_public, [""]), i).address : "",
      length(google_compute_address.eta_public) > 0 ? element(coalescelist(google_compute_address.eta_public, [""]), i).address : "",
      length(google_compute_address.theta_public) > 0 ? element(coalescelist(google_compute_address.theta_public, [""]), i).address : "",
    ])
  ]
  private_ips = [for i in range(0, var.num_instances) :
    concat([
      length(google_compute_address.alpha_private) > 0 ? element(coalescelist(google_compute_address.alpha_private, [""]), i).address : "",
      length(google_compute_address.beta_private) > 0 ? element(coalescelist(google_compute_address.beta_private, [""]), i).address : ""],
      element(local.internal_subnetwork_network_ips, i)
    )
  ]
  public_ips = [for i in range(0, var.num_instances) :
    concat([
      length(google_compute_address.alpha_public) > 0 ? google_compute_address.alpha_public[i].address : "",
      length(google_compute_address.beta_public) > 0 ? google_compute_address.beta_public[i].address : ""],
      element(local.internal_subnetwork_public_ips, i)
    )
  ]
}
