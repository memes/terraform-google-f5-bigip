terraform {
  required_version = "> 0.12"
}

# Randomise the zones to be used by modules
data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
  status  = "UP"
}

resource "random_shuffle" "zones" {
  input = data.google_compute_zones.available.names
  keepers = {
    prefix = var.prefix
    region = var.region
  }
}

locals {
  # External is always alpha
  external_subnetwork = var.alpha_subnet
  # Management is set only if num_nics > 1
  management_subnetwork = var.num_nics > 1 ? var.beta_subnet : ""
  internal_subnetworks = var.num_nics > 2 ? slice([
    var.gamma_subnet,
    var.delta_subnet,
    var.epsilon_subnet,
    var.zeta_subnet,
    var.eta_subnet,
    var.theta_subnet,
  ], 0, var.num_nics - 2) : []
}

module "configsync_fw" {
  source                   = "../../../modules/configsync-fw/"
  project_id               = var.project_id
  bigip_service_account    = var.service_account
  dataplane_network        = var.num_nics > 2 ? var.gamma_net : var.alpha_net
  management_network       = var.beta_net
  dataplane_firewall_name  = format("%.64s", format(format("%s-%s-data", var.prefix, var.instance_name_template), 0))
  management_firewall_name = format("%.64s", format(format("%s-%s-mgt", var.prefix, var.instance_name_template), 0))
}

module "ha" {
  source                            = "../../../modules/ha/"
  project_id                        = var.project_id
  zones                             = random_shuffle.zones.result
  num_instances                     = var.num_instances
  instance_name_template            = format("%s-%s", var.prefix, var.instance_name_template)
  instance_ordinal_offset           = var.instance_ordinal_offset
  domain_name                       = var.domain_name
  metadata                          = var.metadata
  labels                            = var.labels
  tags                              = var.tags
  min_cpu_platform                  = var.min_cpu_platform
  machine_type                      = var.machine_type
  service_account                   = var.service_account
  automatic_restart                 = var.automatic_restart
  preemptible                       = var.preemptible
  ssh_keys                          = var.ssh_keys
  enable_serial_console             = var.enable_serial_console
  image                             = var.image
  delete_disk_on_destroy            = var.delete_disk_on_destroy
  disk_type                         = var.disk_type
  disk_size_gb                      = var.disk_size_gb
  external_subnetwork               = local.external_subnetwork
  provision_external_public_ip      = var.provision_external_public_ip
  external_subnetwork_tier          = var.external_subnetwork_tier
  external_subnetwork_network_ips   = local.external_subnetwork_network_ips
  external_subnetwork_public_ips    = local.external_subnetwork_public_ips
  external_subnetwork_vip_cidrs     = local.external_subnetwork_vip_cidrs
  management_subnetwork             = local.management_subnetwork
  provision_management_public_ip    = var.provision_management_public_ip
  management_subnetwork_tier        = var.management_subnetwork_tier
  management_subnetwork_network_ips = local.management_subnetwork_network_ips
  management_subnetwork_public_ips  = local.management_subnetwork_public_ips
  management_subnetwork_vip_cidrs   = local.management_subnetwork_vip_cidrs
  internal_subnetworks              = local.internal_subnetworks
  provision_internal_public_ip      = var.provision_internal_public_ip
  internal_subnetwork_tier          = var.internal_subnetwork_tier
  internal_subnetwork_network_ips   = local.internal_subnetwork_network_ips
  internal_subnetwork_public_ips    = local.internal_subnetwork_public_ips
  internal_subnetwork_vip_cidrs     = local.internal_subnetwork_vip_cidrs
  allow_phone_home                  = var.allow_phone_home
  default_gateway                   = var.default_gateway
  use_cloud_init                    = var.use_cloud_init
  # allow override of admin_password_secret_manager_key from kitchen.yml
  admin_password_secret_manager_key = coalesce(var.override_admin_password_secret_manager_key, var.admin_password_secret_manager_key)
  secret_implementor                = var.secret_implementor
  custom_script                     = var.custom_script
  as3_payloads                      = var.as3_payloads
  do_payloads                       = var.do_payloads
  ntp_servers                       = var.ntp_servers
  timezone                          = var.timezone
  modules                           = var.modules
  dns_servers                       = var.dns_servers
  search_domains                    = var.search_domains
  install_cloud_libs                = var.install_cloud_libs
  extramb                           = var.extramb
}
