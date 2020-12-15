terraform {
  required_version = "~> 0.12.28, < 0.13"
  required_providers {
    google = ">= 3.48"
  }
  experiments = [variable_validation]
}

resource "random_id" "role_id" {
  byte_length = 4

  keepers = {
    target_type = var.target_type
    target_id   = var.target_id
  }
}

# Create a custom project role for CFE; BIG-IP service accounts will be granted
# this role, in addition to standard logging and monitoring roles.
module "cfe_role" {
  source       = "terraform-google-modules/iam/google//modules/custom_role_iam"
  version      = "6.4.0"
  target_level = var.target_type
  target_id    = var.target_id
  role_id      = coalesce(var.id, format("bigip_cfe_%s", random_id.role_id.hex))
  title        = var.title
  description  = <<EOD
Allow BIG-IP Cloud Failover Extension to fully manage instance, network, route,
and storage resources
EOD
  permissions = [
    "compute.forwardingRules.get",
    "compute.forwardingRules.list",
    "compute.forwardingRules.setTarget",
    "compute.instances.create",
    "compute.instances.get",
    "compute.instances.list",
    "compute.instances.updateNetworkInterface",
    "compute.networks.updatePolicy",
    "compute.routes.create",
    "compute.routes.delete",
    "compute.routes.get",
    "compute.routes.list",
    "compute.targetInstances.get",
    "compute.targetInstances.list",
    "compute.targetInstances.use",
    "storage.buckets.create",
    "storage.buckets.delete",
    "storage.buckets.get",
    "storage.buckets.list",
    "storage.buckets.update",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.get",
    "storage.objects.list",
    "storage.objects.update"
  ]
  members = var.members
}
