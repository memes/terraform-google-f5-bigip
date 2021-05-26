terraform {
  required_version = "> 0.12"
  required_providers {
    google = ">= 3.48"
  }
}

locals {
  hostnames = [for i in range(0, var.num_instances) : format("%s.%s", format(var.instance_name_template, i + var.instance_ordinal_offset), coalesce(var.domain_name, format("%s.c.%s.internal", element(var.zones, i), var.project_id)))]
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
  extramb                         = var.extramb
  default_gateway                 = var.default_gateway
}

# Generate metadata for each instance
module "metadata" {
  source                            = "./modules/metadata/"
  num_instances                     = var.num_instances
  image                             = var.image
  enable_serial_console             = var.enable_serial_console
  ssh_keys                          = var.ssh_keys
  metadata                          = var.metadata
  admin_password_secret_manager_key = var.admin_password_secret_manager_key
  secret_implementor                = var.secret_implementor
  custom_script                     = var.custom_script
  use_cloud_init                    = var.use_cloud_init
  do_filter_jq                      = module.do_payloads.jq_filter
  do_payloads                       = coalescelist(var.do_payloads, module.do_payloads.do_payloads)
  as3_payloads                      = var.as3_payloads
  install_cloud_libs                = var.install_cloud_libs
  extramb                           = var.extramb
}

resource "google_compute_instance" "bigip" {
  count    = var.num_instances
  project  = var.project_id
  name     = format(var.instance_name_template, count.index + var.instance_ordinal_offset)
  hostname = element(local.hostnames, count.index)
  zone     = element(var.zones, count.index)
  labels   = var.labels
  metadata = element(module.metadata.metadata, count.index)

  # Scheduling options
  min_cpu_platform = var.min_cpu_platform
  machine_type     = var.machine_type
  service_account {
    email = var.service_account
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  scheduling {
    automatic_restart = var.automatic_restart
    preemptible       = var.preemptible
  }

  boot_disk {
    auto_delete = var.delete_disk_on_destroy
    initialize_params {
      type  = var.disk_type
      size  = var.disk_size_gb
      image = var.image
    }

  }

  # Networking properties
  tags           = var.tags
  can_ip_forward = true

  # First nic will be attached to the external network; this is the only
  # interface that REQUIRES a subnetwork self-link.
  network_interface {
    subnetwork = var.external_subnetwork
    network_ip = length(var.external_subnetwork_network_ips) > count.index ? element(var.external_subnetwork_network_ips, count.index) : ""

    dynamic "access_config" {
      for_each = compact(var.provision_external_public_ip ? ["1"] : [])
      content {
        network_tier = var.external_subnetwork_tier
        nat_ip       = length(var.external_subnetwork_public_ips) > count.index ? element(var.external_subnetwork_public_ips, count.index) : ""
      }
    }

    dynamic "alias_ip_range" {
      for_each = length(var.external_subnetwork_vip_cidrs) > count.index ? element(var.external_subnetwork_vip_cidrs, count.index) : []
      content {
        ip_cidr_range         = alias_ip_range.value
        subnetwork_range_name = var.external_subnetwork_vip_cidrs_named_range
      }
    }
  }

  # Second NIC will be attached to the management network, if provided.
  dynamic "network_interface" {
    for_each = toset(compact([var.management_subnetwork]))
    content {
      subnetwork = network_interface.value
      network_ip = length(var.management_subnetwork_network_ips) > count.index ? element(var.management_subnetwork_network_ips, count.index) : ""

      dynamic "access_config" {
        for_each = compact(var.provision_management_public_ip ? ["1"] : [])
        content {
          network_tier = var.management_subnetwork_tier
          nat_ip       = length(var.management_subnetwork_public_ips) > count.index ? element(var.management_subnetwork_public_ips, count.index) : ""
        }
      }

      dynamic "alias_ip_range" {
        for_each = length(var.management_subnetwork_vip_cidrs) > count.index ? element(var.management_subnetwork_vip_cidrs, count.index) : []
        content {
          ip_cidr_range         = alias_ip_range.value
          subnetwork_range_name = var.management_subnetwork_vip_cidrs_named_range
        }
      }

    }
  }

  # Assign NIC2-8 to any internal subnetworks, and will never receive a public
  # IP address
  dynamic "network_interface" {
    for_each = { for subnet in var.internal_subnetworks : index(var.internal_subnetworks, subnet) => subnet }
    content {
      subnetwork = network_interface.value
      network_ip = length(var.internal_subnetwork_network_ips) > count.index ? element(coalescelist(element(var.internal_subnetwork_network_ips, count.index), [""]), network_interface.key) : ""

      dynamic "access_config" {
        for_each = compact(var.provision_internal_public_ip ? ["1"] : [])
        content {
          network_tier = var.internal_subnetwork_tier
          nat_ip       = length(var.internal_subnetwork_public_ips) > count.index ? element(coalescelist(element(var.internal_subnetwork_public_ips, count.index), [""]), network_interface.key) : ""
        }
      }

      dynamic "alias_ip_range" {
        for_each = length(var.internal_subnetwork_vip_cidrs) > count.index && length(element(coalescelist(var.internal_subnetwork_vip_cidrs, [""]), count.index)) > network_interface.key ? element(element(var.internal_subnetwork_vip_cidrs, count.index), network_interface.key) : []
        content {
          ip_cidr_range         = alias_ip_range.value
          subnetwork_range_name = length(var.internal_subnetwork_vip_cidrs_named_ranges) > network_interface.key ? element(var.internal_subnetwork_vip_cidrs_named_ranges, network_interface.key) : ""
        }
      }
    }
  }
}
