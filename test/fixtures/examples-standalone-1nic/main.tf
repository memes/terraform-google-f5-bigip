terraform {
  required_version = "> 0.12"
}

# Randomise the zones to be used by modules
data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
  status  = "UP"
}

resource "random_shuffle" "zones" {
  input = data.google_compute_zones.available.names
  keepers = {
    prefix = var.prefix
    region = var.region
  }
}

module "example" {
  source             = "../../../examples/standalone-1nic/"
  project_id         = var.project_id
  num_instances      = var.num_instances
  zone               = element(random_shuffle.zones.result, 0)
  subnet             = var.alpha_subnet
  service_account    = var.service_account
  image              = var.image
  admin_password_key = var.admin_password_secret_manager_key
}
