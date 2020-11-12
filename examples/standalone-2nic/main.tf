# Example Terraform to create a three-NIC instance of BIG-IP using default
# compute service account, and a Marketplace PAYG image.
#
# Note: values to be updated by implementor are shown as [ITEM], where ITEM should
# be changed to the correct resource name/identifier.

# Only supported on Terraform 0.12
terraform {
  required_version = "~> 0.12"
}

module "instance" {
  source                            = "git::https://github.com/memes/f5-google-terraform-modules//modules/big-ip/instance?ref=1.1.1"
  project_id                        = var.project_id
  zones                             = [var.zone]
  service_account                   = var.service_account
  external_subnetwork               = var.external_subnet
  management_subnetwork             = var.management_subnet
  image                             = var.image
  allow_phone_home                  = false
  allow_usage_analytics             = false
  admin_password_secret_manager_key = var.admin_password_key
}
