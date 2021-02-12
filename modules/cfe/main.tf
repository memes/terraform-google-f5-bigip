terraform {
  required_version = "> 0.12"
  required_providers {
    google = ">= 3.48"
  }
}
locals {
  cfe_payload = coalesce(var.cfe_payload, templatefile("${path.module}/templates/cfe.json", {
    cfe_label_key   = var.cfe_label_key
    cfe_label_value = var.cfe_label_value
  }))
  # Add the CFE JSON to metadata
  metadata = merge(var.metadata, {
    cfe_payload = base64gzip(local.cfe_payload)
  })
}

# CFE deployment is simply HA with a custom script to apply CFE JSON
module "ha" {
  source                  = "./../ha/"
  project_id              = var.project_id
  zones                   = var.zones
  num_instances           = var.num_instances
  instance_name_template  = var.instance_name_template
  instance_ordinal_offset = var.instance_ordinal_offset
  domain_name             = var.domain_name
  search_domains          = var.search_domains
  metadata                = local.metadata
  # Make sure the labels applied to instances have the CFE specific key-value pair
  labels                          = merge(var.labels, { "${var.cfe_label_key}" = var.cfe_label_value })
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
  external_subnetwork_vip_cidrs     = var.external_subnetwork_vip_cidrs
  management_subnetwork             = var.management_subnetwork
  provision_management_public_ip    = var.provision_management_public_ip
  management_subnetwork_tier        = var.management_subnetwork_tier
  management_subnetwork_network_ips = var.management_subnetwork_network_ips
  management_subnetwork_public_ips  = var.management_subnetwork_public_ips
  # Only apply VIPs to first instance
  management_subnetwork_vip_cidrs = var.management_subnetwork_vip_cidrs
  internal_subnetworks            = var.internal_subnetworks
  provision_internal_public_ip    = var.provision_internal_public_ip
  internal_subnetwork_tier        = var.internal_subnetwork_tier
  internal_subnetwork_network_ips = var.internal_subnetwork_network_ips
  internal_subnetwork_public_ips  = var.internal_subnetwork_public_ips
  # Only apply VIPs to first instance
  internal_subnetwork_vip_cidrs     = var.internal_subnetwork_vip_cidrs
  allow_phone_home                  = var.allow_phone_home
  default_gateway                   = var.default_gateway
  use_cloud_init                    = var.use_cloud_init
  admin_password_secret_manager_key = var.admin_password_secret_manager_key
  secret_implementor                = var.secret_implementor
  as3_payloads                      = var.as3_payloads
  do_payloads                       = var.do_payloads
  install_cloud_libs                = var.install_cloud_libs
  custom_script                     = file("${path.module}/files/cloudFailoverExtension.sh")
  extramb                           = var.extramb
  ntp_servers                       = var.ntp_servers
  timezone                          = var.timezone
  modules                           = var.modules
  dns_servers                       = var.dns_servers
}
