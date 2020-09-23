terraform {
  required_version = "~> 0.12"
  required_providers {
    google = ">= 3.19"
  }
  experiments = [variable_validation]
}

# CFE requirements for firewall are the same as HA
module "ha_firewall" {
  source                   = "../../ha/firewall/"
  project_id               = var.project_id
  bigip_service_account    = var.bigip_service_account
  management_firewall_name = var.management_firewall_name
  management_network       = var.management_network
  dataplane_firewall_name  = var.dataplane_firewall_name
  dataplane_network        = var.dataplane_network
}
