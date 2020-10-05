terraform {
  required_version = "~> 0.12"
  required_providers {
    google      = ">= 3.40"
    google-beta = ">= 3.40"
  }
  experiments = [variable_validation]
}

locals {
  as3_payloads = coalescelist(var.as3_payloads, [for i in range(0, var.num_instances) : templatefile("${path.module}/templates/as3.json",
    {
      health_check_port = var.health_check_port,
      health_check_vips = "0.0.0.0"
    }
  )])
  do_payloads = coalescelist(var.do_payloads, [for i in range(0, var.num_instances) : templatefile("${path.module}/templates/do.json",
    {
      # Hostname *must* be fully-qualified; if domain_name is unspecified leave
      # blank to allow run-time to use DHCP name.
      hostname         = var.domain_name != "" ? format("%s-%d.%s", var.group_name, i, var.domain_name) : ""
      allow_phone_home = var.allow_phone_home,
      ntp_servers      = var.ntp_servers,
      dns_servers      = var.dns_servers,
      search_domains   = coalescelist(var.search_domains, compact(["google.internal", var.domain_name])),
      timezone         = var.timezone,
      modules          = var.modules,
    }
  )])
}

module "template" {
  source                            = "./instance-template/"
  project_id                        = var.project_id
  region                            = var.region
  instance_name_prefix              = var.group_name
  description                       = var.description
  metadata                          = var.metadata
  labels                            = var.labels
  tags                              = var.tags
  min_cpu_platform                  = var.min_cpu_platform
  machine_type                      = var.machine_type
  service_account                   = var.service_account
  automatic_restart                 = var.automatic_restart
  preemptible                       = var.preemptible
  ssh_keys                          = var.ssh_keys
  enable_os_login                   = var.enable_os_login
  enable_serial_console             = var.enable_serial_console
  image                             = var.image
  delete_disk_on_destroy            = var.delete_disk_on_destroy
  disk_type                         = var.disk_type
  disk_size_gb                      = var.disk_size_gb
  external_subnetwork               = var.external_subnetwork
  provision_external_public_ip      = var.provision_external_public_ip
  external_subnetwork_tier          = var.external_subnetwork_tier
  management_subnetwork             = var.management_subnetwork
  provision_management_public_ip    = var.provision_management_public_ip
  management_subnetwork_tier        = var.management_subnetwork_tier
  internal_subnetworks              = var.internal_subnetworks
  provision_internal_public_ip      = var.provision_internal_public_ip
  internal_subnetwork_tier          = var.internal_subnetwork_tier
  allow_usage_analytics             = var.allow_usage_analytics
  allow_phone_home                  = var.allow_phone_home
  license_type                      = var.license_type
  default_gateway                   = var.default_gateway
  use_cloud_init                    = var.use_cloud_init
  admin_password_secret_manager_key = var.admin_password_secret_manager_key
  custom_script                     = var.custom_script
  ntp_servers                       = var.ntp_servers
  timezone                          = var.timezone
  modules                           = var.modules
  dns_servers                       = var.dns_servers
  search_domains                    = var.search_domains
  install_cloud_libs                = var.install_cloud_libs
}

data "google_compute_subnetwork" "external" {
  self_link = var.external_subnetwork
}

# Create a service account limited firewall rule that permits GCP health-check
# to specified port.
resource "google_compute_firewall" "mig_hc" {
  project     = var.project_id
  name        = var.health_check_firewall_name
  network     = data.google_compute_subnetwork.external.network
  description = "Allow health-check to BIG-IP instances on external"
  direction   = "INGRESS"
  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
  ]
  target_service_accounts = [
    var.service_account
  ]
  allow {
    protocol = "tcp"
    ports = [
      var.health_check_port
    ]
  }
}

resource "google_compute_health_check" "bigip" {
  project             = var.project_id
  name                = var.health_check_name
  description         = format("%s MIG health check", var.health_check_name)
  check_interval_sec  = var.health_check_interval_sec
  timeout_sec         = var.health_check_timeout_sec
  healthy_threshold   = var.health_check_healthy_threshold
  unhealthy_threshold = var.health_check_unhealthy_threshold

  http_health_check {
    host               = var.health_check_http_host
    request_path       = var.health_check_http_path
    response           = var.health_check_http_response_text
    port               = var.health_check_port
    port_specification = "USE_FIXED_PORT"
  }
}

resource "google_compute_region_instance_group_manager" "bigip" {
  project            = var.project_id
  name               = var.group_name
  base_instance_name = var.group_name
  region             = var.region
  description        = format("MIG for %s", var.group_name)
  target_size        = var.num_instances
  wait_for_instances = false

  version {
    name              = var.group_name
    instance_template = module.template.self_link
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.bigip.self_link
    initial_delay_sec = 300
  }

  update_policy {
    type                         = "OPPORTUNISTIC"
    instance_redistribution_type = "NONE"
    minimal_action               = "RESTART"
    max_surge_fixed              = 3
    max_unavailable_fixed        = 3
    min_ready_sec                = 300
  }

  distribution_policy_zones = var.distribution_policy_zones

  stateful_disk {
    device_name = "boot"
    delete_rule = "ON_PERMANENT_INSTANCE_DELETION"
  }
}
