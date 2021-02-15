# Example Terraform to create a single-NIC instance of BIG-IP using default
# compute service account, and a Marketplace PAYG image.

# Only supported on Terraform 0.12
terraform {
  required_version = "~> 0.12.28, < 0.13"
}

module "instance" {
  /* TODO: @memes
  source                            = "memes/f5-bigip/google"
  version                           = "1.3.2"
  */
  source                            = "../../"
  project_id                        = var.project_id
  num_instances                     = var.num_instances
  zones                             = [var.zone]
  service_account                   = var.service_account
  external_subnetwork               = var.subnet
  image                             = var.image
  admin_password_secret_manager_key = var.admin_password_key
}
