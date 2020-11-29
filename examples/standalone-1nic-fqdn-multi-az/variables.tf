variable "project_id" {
  type        = string
  description = <<EOD
The GCP project identifier where the cluster will be created.
EOD
}

variable "zone" {
  type        = string
  description = <<EOD
The compute zone which will host the BIG-IP VMs.
EOD
}

variable "subnet" {
  type        = string
  description = <<EOD
The fully-qualified subnetwork self-link to attach to the BIG-IP VM.
EOD
}

variable "admin_password_key" {
  type        = string
  description = <<EOD
The Secret Manager key to lookup and retrive admin user password during
initialization.
EOD
}

variable "service_account" {
  type        = string
  description = <<EOD
The service account to use for BIG-IP VMs.
EOD
}

variable "image" {
  type        = string
  default     = "projects/f5-7626-networks-public/global/images/f5-bigip-15-0-1-3-0-0-4-payg-good-5gbps-200318182229"
  description = <<EOD
The BIG-IP image to use. Defaults to the latest v15 PAYG/good/5gbps
release as of the publishing of this module.
EOD
}

variable "instance_name_template" {
  type        = string
  description = <<EOD
A format string that will be used when naming instance, that should include a
format token for including ordinal number. E.g. 'bigip-%d', such that %d will
be replaced with the ordinal of each instance.
EOD
}

variable "domain_name" {
  type        = string
  description = <<EOD
The domain name to use when setting FQDN of instances.
EOD
}
