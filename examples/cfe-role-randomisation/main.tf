# Example Terraform to create a CFE custom-role with a random id.

# Only supported on Terraform 0.12
terraform {
  required_version = "~> 0.12.28, < 0.13"
}

# Create a custom CFE role with semi-random id
module "cfe_role" {
  /* TODO: @memes
  source      = "memes/f5-bigip/google//modules/cfe-role"
  version     = "1.3.2"
  */
  source      = "../../modules/cfe-role/"
  target_type = "project"
  target_id   = var.project_id
  id          = var.id
  members     = var.members
}
