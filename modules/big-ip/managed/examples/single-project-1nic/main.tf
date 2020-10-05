# Example Terraform to create a  Stateful Regional Managed Instance Group of
# single-NIC BIG-IP instances using a Marketplace PAYG image.

# Only supported on Terraform 0.12
terraform {
  required_version = "~> 0.12"
}

module "mig" {
  source                            = "../../"
  project_id                        = var.project_id
  num_instances                     = var.num_instances
  region                            = var.region
  service_account                   = var.service_account
  external_subnetwork               = var.subnet
  image                             = var.image
  allow_phone_home                  = false
  allow_usage_analytics             = false
  admin_password_secret_manager_key = var.admin_password_key
}
