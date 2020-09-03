terraform {
  required_version = "~> 0.12"
  required_providers {
    google = ">= 3.19"
  }
  experiments = [variable_validation]
}


locals {
  hostnames = [for i in range(0, var.num_instances) : format("%s.%s.c.%s.internal", format(var.instance_name_template, i), var.zone, var.project_id)]
  # Use first internal network addresses for sync group (per published guidelines)
  # if there is at least one internal subnet defined. Fallback to external (nic0)
  sync_group_addresses = length(var.internal_subnetworks) > 0 ? [for i in range(0, var.num_instances) : element(element(var.internal_subnetwork_network_ips, i), 0)] : var.external_subnetwork_network_ips
  do_payloads = coalescelist(var.do_payloads, [for i in range(0, var.num_instances) : templatefile("${path.module}/templates/do.json", {
    hostname               = element(local.hostnames, i)
    allow_phone_home       = var.allow_phone_home
    dns_servers            = var.dns_servers
    search_domains         = coalescelist(var.search_domains, ["google.internal", format("%s.c.%s.internal", var.zone, var.project_id)])
    ntp_servers            = var.ntp_servers
    timezone               = var.timezone
    modules                = var.modules
    sync_address           = element(local.sync_group_addresses, i)
    failover_address       = element(local.sync_group_addresses, i)
    failover_group_members = local.hostnames
    auto_sync              = true
    save_on_auto_sync      = false
    network_failover       = true
    fullload_on_sync       = false
    asm_sync               = false
    # All instances trust primary, except primary which has to trust first secondary
    remote_host = element(local.sync_group_addresses, i == 0 ? 1 : 0)
  })])
}

module "instance" {
  source                          = "./../instance/"
  project_id                      = var.project_id
  zone                            = var.zone
  num_instances                   = var.num_instances
  instance_name_template          = var.instance_name_template
  description                     = var.description
  metadata                        = var.metadata
  labels                          = var.labels
  tags                            = var.tags
  min_cpu_platform                = var.min_cpu_platform
  machine_type                    = var.machine_type
  service_account                 = var.service_account
  automatic_restart               = var.automatic_restart
  preemptible                     = var.preemptible
  ssh_keys                        = var.ssh_keys
  enable_os_login                 = var.enable_os_login
  enable_serial_console           = var.enable_serial_console
  image                           = var.image
  delete_disk_on_destroy          = var.delete_disk_on_destroy
  disk_type                       = var.disk_type
  disk_size_gb                    = var.disk_size_gb
  external_subnetwork             = var.external_subnetwork
  provision_external_public_ip    = var.provision_external_public_ip
  external_subnetwork_tier        = var.external_subnetwork_tier
  external_subnetwork_network_ips = var.external_subnetwork_network_ips
  # Only apply VIPs to first instance
  external_subnetwork_vip_cidrs     = [var.external_subnetwork_vip_cidrs]
  management_subnetwork             = var.management_subnetwork
  provision_management_public_ip    = var.provision_management_public_ip
  management_subnetwork_tier        = var.management_subnetwork_tier
  management_subnetwork_network_ips = var.management_subnetwork_network_ips
  # Only apply VIPs to first instance
  management_subnetwork_vip_cidrs = [var.management_subnetwork_vip_cidrs]
  internal_subnetworks            = var.internal_subnetworks
  provision_internal_public_ip    = var.provision_internal_public_ip
  internal_subnetwork_tier        = var.internal_subnetwork_tier
  internal_subnetwork_network_ips = var.internal_subnetwork_network_ips
  # Only apply VIPs to first instance
  internal_subnetwork_vip_cidrs     = [var.internal_subnetwork_vip_cidrs]
  allow_usage_analytics             = var.allow_usage_analytics
  allow_phone_home                  = var.allow_phone_home
  license_type                      = var.license_type
  default_gateway                   = var.default_gateway
  use_cloud_init                    = var.use_cloud_init
  admin_password_secret_manager_key = var.admin_password_secret_manager_key
  as3_payloads                      = var.as3_payloads
  do_payloads                       = local.do_payloads
}
