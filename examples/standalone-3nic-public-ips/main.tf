# Example Terraform to create a three-NIC instance of BIG-IP using default
# compute service account, and a Marketplace PAYG image.
#
# Note: values to be updated by implementor are shown as [ITEM], where ITEM should
# be changed to the correct resource name/identifier.

# Only supported on Terraform 0.13 and Terraform 0.14
terraform {
  required_version = "~> 0.12.28, < 0.13"
}

# Reserve public IP on external subnet for BIG-IP nic0
resource "google_compute_address" "ext_public" {
  project      = var.project_id
  name         = "bigip-ext-public"
  region       = replace(var.zone, "/-[a-z]$/", "")
  address_type = "EXTERNAL"
}

# Reserve public IP on management subnet for BIG-IP nic1
resource "google_compute_address" "mgt_public" {
  project      = var.project_id
  name         = "bigip-mgt-public"
  region       = replace(var.zone, "/-[a-z]$/", "")
  address_type = "EXTERNAL"
}

# Reserve public IP on internal subnet for BIG-IP nic2
resource "google_compute_address" "int_public" {
  project      = var.project_id
  name         = "bigip-int-public"
  region       = replace(var.zone, "/-[a-z]$/", "")
  address_type = "EXTERNAL"
}

module "instance" {
  /* TODO: @memes
  source                = "memes/f5-bigip/google"
  version               = "1.3.2"
  */
  source                           = "../../"
  project_id                       = var.project_id
  zones                            = [var.zone]
  service_account                  = var.service_account
  external_subnetwork              = var.external_subnet
  provision_external_public_ip     = true
  external_subnetwork_public_ips   = [google_compute_address.ext_public.address]
  management_subnetwork            = var.management_subnet
  provision_management_public_ip   = true
  management_subnetwork_public_ips = [google_compute_address.mgt_public.address]
  # BIG-IP template accepts 1-6 NICs for internal network, just pass in a list
  # of self-links
  internal_subnetworks              = [var.internal_subnet]
  provision_internal_public_ip      = true
  internal_subnetwork_public_ips    = [[google_compute_address.int_public.address]]
  image                             = var.image
  allow_phone_home                  = false
  allow_usage_analytics             = false
  admin_password_secret_manager_key = var.admin_password_key
}
