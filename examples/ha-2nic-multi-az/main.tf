# Example Terraform to create a three-NIC instance of BIG-IP using default
# compute service account, and a Marketplace PAYG image.
#
# Note: values to be updated by implementor are shown as [ITEM], where ITEM should
# be changed to the correct resource name/identifier.

# Only supported on Terraform 0.13
terraform {
  required_version = "~> 0.13.5"
}

# Create a firewall rule to allow BIG-IP ConfigSync
module "ha_fw" {
  source                = "memes/f5-bigip/google//modules/configsync-fw"
  version               = "2.0.1"
  project_id            = var.project_id
  bigip_service_account = var.service_account
  dataplane_network     = var.external_network
  management_network    = var.management_network
}

locals {
  region = replace(element(var.zones, 0), "/-[a-z]$/", "")
}

# Reserve IPs on external subnet for BIG-IP nic0s
resource "google_compute_address" "ext" {
  count        = var.num_instances
  project      = var.project_id
  name         = format("bigip-ext-%d", count.index)
  subnetwork   = var.external_subnet
  address_type = "INTERNAL"
  region       = local.region
}

# Reserve IPs on management subnet for BIG-IP nic1s
resource "google_compute_address" "mgt" {
  count        = var.num_instances
  project      = var.project_id
  name         = format("bigip-mgt-%d", count.index)
  subnetwork   = var.management_subnet
  address_type = "INTERNAL"
  region       = local.region
}

module "ha" {
  /* TODO: m.emes@f5.com
  source                            = "memes/f5-bigip/google//modules/ha"
  version                           = "2.0.1"
  */
  source                            = "../../modules/ha/"
  project_id                        = var.project_id
  num_instances                     = var.num_instances
  zones                             = var.zones
  machine_type                      = "n1-standard-8"
  service_account                   = var.service_account
  external_subnetwork               = var.external_subnet
  external_subnetwork_network_ips   = [for r in google_compute_address.ext : r.address]
  management_subnetwork             = var.management_subnet
  management_subnetwork_network_ips = [for r in google_compute_address.mgt : r.address]
  image                             = var.image
  allow_phone_home                  = false
  allow_usage_analytics             = false
  admin_password_secret_manager_key = var.admin_password_key
}
