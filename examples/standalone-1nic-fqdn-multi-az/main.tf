# Example Terraform to create a single-NIC instance of BIG-IP using default
# compute service account, and a Marketplace PAYG image.

# Only supported on Terraform 0.13
terraform {
  required_version = "~> 0.13.5"
}

module "instance" {
  /* TODO m.emes@f5.com
  source                            = "memes/f5-bigip/google"
  version                           = "2.0.1"
  */
  source                            = "../../"
  project_id                        = var.project_id
  zones                             = [var.zone]
  service_account                   = var.service_account
  external_subnetwork               = var.subnet
  image                             = var.image
  allow_phone_home                  = false
  allow_usage_analytics             = false
  admin_password_secret_manager_key = var.admin_password_key
  instance_name_template            = var.instance_name_template
  domain_name                       = var.domain_name
}
