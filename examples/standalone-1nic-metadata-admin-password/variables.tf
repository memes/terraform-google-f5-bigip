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
The metadata key to lookup and retrive admin user password during initialization.
EOD
}

variable "secret_implementor" {
  type        = string
  description = <<EOD
The implementation to use for secret retrieval.
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
  default     = "projects/f5-7626-networks-public/global/images/f5-bigip-15-1-2-1-0-0-10-payg-good-5gbps-210115160742"
  description = <<EOD
The BIG-IP image to use. Defaults to the latest v15 PAYG/good/5gbps
release as of the publishing of this module.
EOD
}

variable "metadata" {
  type        = map(string)
  description = <<EOD
Additional metadata values to pass to instances. For the demo that should include
an admin user password in cleartext associated with the key whose value matches
`admin_pasword_key`.
EOD
}
