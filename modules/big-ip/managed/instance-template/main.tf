terraform {
  required_version = "~> 0.12"
  required_providers {
    google = ">= 3.40"
  }
  experiments = [variable_validation]
}

# Generate metadata that will be embedded in the shared instance template
module "metadata" {
  source                            = "./../../metadata/"
  num_instances                     = 1
  region                            = var.region
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
  search_domains                    = coalescelist(var.search_domains, ["google.internal"])
  install_cloud_libs                = var.install_cloud_libs
  do_payloads                       = var.do_payloads
  as3_payloads                      = var.as3_payloads
}

resource "google_compute_instance_template" "bigip" {
  project              = var.project_id
  name_prefix          = format("%s-", var.instance_name_prefix)
  instance_description = var.description
  region               = var.region
  labels               = var.labels
  # Default to zeroth metadata as the common-to-all-instances metadata
  metadata = element(module.metadata.metadata, 0)

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

  disk {
    auto_delete  = var.delete_disk_on_destroy
    boot         = true
    device_name  = "boot"
    disk_type    = var.disk_type
    disk_size_gb = var.disk_size_gb
    source_image = var.image
  }

  # Networking properties
  tags           = var.tags
  can_ip_forward = true

  # First nic will be attached to the external network; this is the only
  # interface that REQUIRES a subnetwork self-link.
  network_interface {
    subnetwork = var.external_subnetwork

    dynamic "access_config" {
      for_each = compact(var.provision_external_public_ip ? ["1"] : [])
      content {
        network_tier = var.external_subnetwork_tier
      }
    }
  }

  # Second NIC will be attached to the management network, if provided.
  dynamic "network_interface" {
    for_each = toset(compact([var.management_subnetwork]))
    content {
      subnetwork = network_interface.value

      dynamic "access_config" {
        for_each = compact(var.provision_management_public_ip ? ["1"] : [])
        content {
          network_tier = var.management_subnetwork_tier
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

      dynamic "access_config" {
        for_each = compact(var.provision_internal_public_ip ? ["1"] : [])
        content {
          network_tier = var.internal_subnetwork_tier
        }
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
