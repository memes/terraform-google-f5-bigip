terraform {
  required_version = "~> 0.12.29, < 0.13"
  required_providers {
    google = ">= 3.48"
  }
  experiments = [variable_validation]
}

locals {
  hostnames = [for i in range(0, var.num_instances) : format("%s.%s", format(var.instance_name_template, i + var.instance_ordinal_offset), coalesce(var.domain_name, format("%s.c.%s.internal", element(var.zones, i), var.project_id)))]
}

# Generate metadata for each instance
module "metadata" {
  source                            = "./modules/metadata/"
  num_instances                     = var.num_instances
  region                            = replace(element(var.zones, 0), "/-[a-z]$/", "")
  license_type                      = var.license_type
  image                             = var.image
  enable_os_login                   = var.enable_os_login
  enable_serial_console             = var.enable_serial_console
  ssh_keys                          = var.ssh_keys
  allow_usage_analytics             = var.allow_usage_analytics
  allow_phone_home                  = var.allow_phone_home
  metadata                          = var.metadata
  default_gateway                   = var.default_gateway
  admin_password_secret_manager_key = var.admin_password_secret_manager_key
  custom_script                     = var.custom_script
  use_cloud_init                    = var.use_cloud_init
  hostnames                         = local.hostnames
  search_domains                    = coalescelist(var.search_domains, compact(flatten(["google.internal", [var.domain_name], [for zone in var.zones : format("%s.c.%s.internal", zone, var.project_id)]])))
  do_payloads                       = var.do_payloads
  as3_payloads                      = var.as3_payloads
  install_cloud_libs                = var.install_cloud_libs
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
      }
    }

    dynamic "alias_ip_range" {
      for_each = length(var.external_subnetwork_vip_cidrs) > count.index ? element(var.external_subnetwork_vip_cidrs, count.index) : []
      content {
        ip_cidr_range = alias_ip_range.value
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
        }
      }

      dynamic "alias_ip_range" {
        for_each = length(var.management_subnetwork_vip_cidrs) > count.index ? element(var.management_subnetwork_vip_cidrs, count.index) : []
        content {
          ip_cidr_range = alias_ip_range.value
        }
      }

    }
  }

  # Assign NIC2-8 to any internal subnetworks, and will never receive a public
  # IP address
  dynamic "network_interface" {
    for_each = toset(var.internal_subnetworks)
    content {
      subnetwork = network_interface.value
      # XXX - handle this correctly
      network_ip = length(var.internal_subnetwork_network_ips) > count.index ? element(element(var.internal_subnetwork_network_ips, count.index), 0) : ""

      dynamic "access_config" {
        for_each = compact(var.provision_internal_public_ip ? ["1"] : [])
        content {
          network_tier = var.internal_subnetwork_tier
        }
      }

      dynamic "alias_ip_range" {
        for_each = length(var.internal_subnetwork_vip_cidrs) > count.index ? element(var.internal_subnetwork_vip_cidrs, count.index) : []
        content {
          ip_cidr_range = alias_ip_range.value
        }
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
