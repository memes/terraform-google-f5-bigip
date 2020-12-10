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

variable "external_subnet" {
  type        = string
  description = <<EOD
The fully-qualified subnetwork self-link to attach to the BIG-IP VM *external*
interface.
EOD
}

variable "management_subnet" {
  type        = string
  description = <<EOD
The fully-qualified subnetwork self-link to attach to the BIG-IP VM *management*
interface.
EOD
}

variable "internal_subnets" {
  type        = list(string)
  description = <<EOD
The list of fully-qualified subnetwork self-links to attach to the BIG-IP VM
*internal* interfaces.
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
  default     = "projects/f5-7626-networks-public/global/images/f5-bigip-15-1-2-0-0-9-payg-good-5gbps-201110225418"
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

variable "external_vips" {
  type        = list(list(string))
  description = <<EOD
A list of list of CIDRs to apply to each instance as an Alias IP (VIP).
EOD
}

variable "internal_vips" {
  type        = list(list(list(string)))
  description = <<EOD
A list of list of list of CIDRs to apply to each instance as an Alias IP (VIP).
EOD
}

variable "num_instances" {
  type        = number
  description = <<EOD
The number of BIG-IP instances to create.
EOD
}
