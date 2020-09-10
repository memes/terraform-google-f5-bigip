# Example Terraform to create a three-NIC instance of BIG-IP using default
# compute service account, and a Marketplace PAYG image.
#
# Note: values to be updated by implementor are shown as [ITEM], where ITEM should
# be changed to the correct resource name/identifier.

# Only supported on Terraform 0.12
terraform {
  required_version = "~> 0.12"
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

# Reserve IPs on management subnet for BIG-IP nic1s
resource "google_compute_address" "mgt" {
  count        = var.num_instances
  project      = var.project_id
  name         = format("bigip-mgt-%d", count.index)
  subnetwork   = var.management_subnet
  address_type = "INTERNAL"
  region       = replace(var.zone, "/-[a-z]$/", "")
}

module "ha" {
  #source              = "https://github.com/memes/f5-google-terraform-modules/modules/big-ip/ha?ref=v1.0.0"
  source                            = "../../"
  project_id                        = var.project_id
  num_instances                     = var.num_instances
  zone                              = var.zone
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
  # Use the management network gateway for default egress
  #default_gateway = "$MGMT_GATEWAY"
  install_cloud_libs = [
    "https://cdn.f5.com/product/cloudsolutions/f5-cloud-libs/v4.22.0/f5-cloud-libs.tar.gz",
    "https://cdn.f5.com/product/cloudsolutions/f5-cloud-libs-gce/v2.6.0/f5-cloud-libs-gce.tar.gz",
    "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.22.1/f5-appsvcs-3.22.1-1.noarch.rpm",
    "https://storage.googleapis.com/download/storage/v1/b/automation-factory-f5-gcs-4138-sales-cloud-sales/o/rpms%2Ff5-declarative-onboarding%2Ff5-declarative-onboarding-1.15.0-3emes.noarch.rpm?alt=media"
  ]
}
