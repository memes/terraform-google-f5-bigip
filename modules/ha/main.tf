terraform {
  required_version = "> 0.12"
  required_providers {
    google = ">= 3.48"
  }
}

locals {
  hostnames = [for i in range(0, var.num_instances) : format("%s.%s", format(var.instance_name_template, i + var.instance_ordinal_offset), coalesce(var.domain_name, format("%s.c.%s.internal", element(var.zones, i), var.project_id)))]
  # Use first internal network addresses for sync group (per published guidelines)
  # if there is at least one internal subnet defined. Fallback to external (nic0)
  sync_self_name       = length(var.internal_subnetworks) > 0 ? "internal-self" : "external-self"
  sync_group_addresses = length(var.internal_subnetworks) > 0 ? [for i in range(0, var.num_instances) : element(element(var.internal_subnetwork_network_ips, i), 0)] : var.external_subnetwork_network_ips
  ha_do_snippets = length(var.do_payloads) > 0 ? [] : [for i in range(0, var.num_instances) : templatefile("${path.module}/templates/do.json", {
    # Self-ip and VLAN name must match the self-ip declared in DO from do-builder
    sync_self_name         = local.sync_self_name
    sync_self_ip           = element(local.sync_group_addresses, i)
    failover_group_members = local.sync_group_addresses
    auto_sync              = true
    save_on_auto_sync      = false
    network_failover       = true
    fullload_on_sync       = false
    asm_sync               = false
  })]
}

# Generate a set of DO payloads *if* none are supplied as an input
module "do_payloads" {
  source                          = "f5devcentral/do-builder/bigip"
  version                         = "1.0.0-rc1"
  num_instances                   = length(var.do_payloads) > 0 ? 0 : var.num_instances
  ntp_servers                     = var.ntp_servers
  timezone                        = var.timezone
  modules                         = var.modules
  allow_phone_home                = var.allow_phone_home
  hostnames                       = local.hostnames
  dns_servers                     = var.dns_servers
  search_domains                  = coalescelist(var.search_domains, compact(flatten(["google.internal", [var.domain_name], [for zone in var.zones : format("%s.c.%s.internal", zone, var.project_id)]])))
  nic_count                       = 1 + length(compact(concat([var.management_subnetwork], var.internal_subnetworks)))
  external_subnetwork_network_ips = var.external_subnetwork_network_ips
  internal_subnetwork_network_ips = var.internal_subnetwork_network_ips
  additional_configs              = local.ha_do_snippets
  # Enable default service on internal interface if present
  allow_service = {
    internal = length(var.internal_subnetworks) > 0 ? "default" : "none"
  }
  default_gateway = var.default_gateway
  extramb         = var.extramb
}

module "instance" {
  source                          = "./../../"
  project_id                      = var.project_id
  zones                           = var.zones
  num_instances                   = var.num_instances
  instance_name_template          = var.instance_name_template
  instance_ordinal_offset         = var.instance_ordinal_offset
  domain_name                     = var.domain_name
  metadata                        = var.metadata
  labels                          = var.labels
  tags                            = var.tags
  min_cpu_platform                = var.min_cpu_platform
  machine_type                    = var.machine_type
  service_account                 = var.service_account
  automatic_restart               = var.automatic_restart
  preemptible                     = var.preemptible
  ssh_keys                        = var.ssh_keys
  enable_serial_console           = var.enable_serial_console
  image                           = var.image
  delete_disk_on_destroy          = var.delete_disk_on_destroy
  disk_type                       = var.disk_type
  disk_size_gb                    = var.disk_size_gb
  external_subnetwork             = var.external_subnetwork
  provision_external_public_ip    = var.provision_external_public_ip
  external_subnetwork_tier        = var.external_subnetwork_tier
  external_subnetwork_network_ips = var.external_subnetwork_network_ips
  external_subnetwork_public_ips  = var.external_subnetwork_public_ips
  # Only apply VIPs to first instance
  external_subnetwork_vip_cidrs             = [var.external_subnetwork_vip_cidrs]
  external_subnetwork_vip_cidrs_named_range = var.external_subnetwork_vip_cidrs_named_range
  management_subnetwork                     = var.management_subnetwork
  provision_management_public_ip            = var.provision_management_public_ip
  management_subnetwork_tier                = var.management_subnetwork_tier
  management_subnetwork_network_ips         = var.management_subnetwork_network_ips
  management_subnetwork_public_ips          = var.management_subnetwork_public_ips
  # Only apply VIPs to first instance
  management_subnetwork_vip_cidrs             = [var.management_subnetwork_vip_cidrs]
  management_subnetwork_vip_cidrs_named_range = var.management_subnetwork_vip_cidrs_named_range
  internal_subnetworks                        = var.internal_subnetworks
  provision_internal_public_ip                = var.provision_internal_public_ip
  internal_subnetwork_tier                    = var.internal_subnetwork_tier
  internal_subnetwork_network_ips             = var.internal_subnetwork_network_ips
  internal_subnetwork_public_ips              = var.internal_subnetwork_public_ips
  # Only apply VIPs to first instance
  internal_subnetwork_vip_cidrs              = [var.internal_subnetwork_vip_cidrs]
  internal_subnetwork_vip_cidrs_named_ranges = var.internal_subnetwork_vip_cidrs_named_ranges
  allow_phone_home                           = var.allow_phone_home
  use_cloud_init                             = var.use_cloud_init
  admin_password_secret_manager_key          = var.admin_password_secret_manager_key
  secret_implementor                         = var.secret_implementor
  custom_script                              = var.custom_script
  as3_payloads                               = var.as3_payloads
  do_payloads                                = coalescelist(var.do_payloads, module.do_payloads.do_payloads)
  install_cloud_libs                         = var.install_cloud_libs
}
