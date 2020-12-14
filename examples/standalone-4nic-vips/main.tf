# Example Terraform to create a three-NIC instance of BIG-IP using default
# compute service account, and a Marketplace PAYG image.
#
# Note: values to be updated by implementor are shown as [ITEM], where ITEM should
# be changed to the correct resource name/identifier.

# Only supported on Terraform 0.12
terraform {
  required_version = "~> 0.12.29, < 0.13"
}

module "instance" {
  /* TODO @memes
  source                = "memes/f5-bigip/google"
  version               = "1.3.2"
  */
  source                        = "../../"
  project_id                    = var.project_id
  num_instances                 = var.num_instances
  zones                         = [var.zone]
  service_account               = var.service_account
  external_subnetwork           = var.external_subnet
  external_subnetwork_vip_cidrs = var.external_vips
  management_subnetwork         = var.management_subnet
  # BIG-IP template accepts 1-6 NICs for internal network, just pass in a list
  # of self-links
  internal_subnetworks              = var.internal_subnets
  internal_subnetwork_vip_cidrs     = var.internal_vips
  image                             = var.image
  allow_phone_home                  = false
  allow_usage_analytics             = false
  admin_password_secret_manager_key = var.admin_password_key
  instance_name_template            = var.instance_name_template
}
