# Example Terraform to create a three-NIC instance of BIG-IP using default
# compute service account, and a Marketplace PAYG image.
#
# Note: values to be updated by implementor are shown as [ITEM], where ITEM should
# be changed to the correct resource name/identifier.

# Only supported on Terraform 0.12
terraform {
  required_version = "~> 0.12.29"
}

# Create a custom CFE role for BIG-IP service account
module "cfe_role" {
  source      = "memes/f5-bigip/google//modules/cfe-role"
  version     = "1.2.2"
  target_type = "project"
  target_id   = var.project_id
  members     = [format("serviceAccount:%s", var.service_account)]
}

# Create a firewall rule to allow BIG-IP ConfigSync and failover
module "cfe_fw" {
  source                = "memes/f5-bigip/google//modules/configsync-fw"
  version               = "1.2.2"
  project_id            = var.project_id
  bigip_service_account = var.service_account
  dataplane_network     = var.internal_network
  management_network    = var.management_network
}

# Reserve IPs on external subnet for BIG-IP nic0s
resource "google_compute_address" "ext" {
  count        = var.num_instances
  project      = var.project_id
  name         = format("bigip-ext-%d", count.index)
  subnetwork   = var.external_subnet
  address_type = "INTERNAL"
  region       = replace(var.zone, "/-[a-z]$/", "")
}

# Reserve VIP on external subnet for BIG-IP
resource "google_compute_address" "vip" {
  project      = var.project_id
  name         = "bigip-ext-vip"
  subnetwork   = var.external_subnet
  address_type = "INTERNAL"
  region       = replace(var.zone, "/-[a-z]$/", "")
}

# Reserve IPs on management subnet for BIG-IP nic1s
resource "google_compute_address" "mgt" {
  count        = var.num_instances
  project      = var.project_id
  name         = format("bigip-mgt-%d", count.index)
  subnetwork   = var.management_subnet
  address_type = "INTERNAL"
  region       = replace(var.zone, "/-[a-z]$/", "")
}

# Reserve IPs on internal subnet for BIG-IP nic2s
resource "google_compute_address" "int" {
  count        = var.num_instances
  project      = var.project_id
  name         = format("bigip-int-%d", count.index)
  subnetwork   = var.internal_subnet
  address_type = "INTERNAL"
  region       = replace(var.zone, "/-[a-z]$/", "")
}

# Random name for CFE bucket
resource "random_id" "bucket" {
  byte_length = 8
}

# Create CFE bucket - use a random value as part of the name so that new bucket
# can be created with same prefix without waiting.
module "cfe_bucket" {
  source     = "terraform-google-modules/cloud-storage/google"
  version    = "1.7.2"
  project_id = var.project_id
  prefix     = "bigip-cfe-example"
  names      = [random_id.bucket.hex]
  force_destroy = {
    "${random_id.bucket.hex}" = true
  }
  location          = "US"
  set_admin_roles   = false
  set_creator_roles = false
  set_viewer_roles  = true
  viewers           = [format("serviceAccount:%s", var.service_account)]
  # Label the bucket with the CFE pair, as supplied to CFE module
  labels = {
    f5_cloud_failover_label = "cfe-example"
  }
}

module "cfe" {
  source                            = "memes/f5-bigip/google//modules/cfe"
  version                           = "1.2.2"
  project_id                        = var.project_id
  num_instances                     = var.num_instances
  zones                             = [var.zone]
  machine_type                      = "n1-standard-8"
  service_account                   = var.service_account
  external_subnetwork               = var.external_subnet
  external_subnetwork_network_ips   = [for r in google_compute_address.ext : r.address]
  external_subnetwork_vip_cidrs     = [google_compute_address.vip.address]
  management_subnetwork             = var.management_subnet
  management_subnetwork_network_ips = [for r in google_compute_address.mgt : r.address]
  internal_subnetworks              = [var.internal_subnet]
  internal_subnetwork_network_ips   = [for r in google_compute_address.int : [r.address]]
  image                             = var.image
  allow_phone_home                  = false
  allow_usage_analytics             = false
  admin_password_secret_manager_key = var.admin_password_key
  cfe_label_key                     = "f5_cloud_failover_label"
  cfe_label_value                   = "cfe-example"
}
