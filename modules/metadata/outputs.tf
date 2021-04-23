output "metadata" {
  value = local.metadata
  # Metadata does not contain sensitive data, but Terraform 0.15 is overly
  # aggressive when some functions are involved. Mark output as sensitive until
  # https://github.com/hashicorp/terraform/issues/27337 is in a 0.15.x release.
  sensitive   = true
  description = <<EOD
The list of metadata maps to apply to instances.
EOD
}
