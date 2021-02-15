#
# These are suite-specific variables that drive behaviour and are not always a
# 1:1 mapping with the inputs of the root module.
#

variable "num_nics" {
  type        = number
  description = <<EOD
The number of network interfaces to provision in BIG-IP test instances.
EOD
}

#
# These inputs will be set from test/setup/harness.tfvars
#

variable "tf_sa_email" {
  type        = string
  default     = ""
  description = <<EOD
The fully-qualified email address of the Terraform service account to use for
resource creation via account impersonation. If left blank, the default, then
the invoker's account will be used.

E.g. if you have permissions to impersonate:

tf_sa_email = "terraform@PROJECT_ID.iam.gserviceaccount.com"
EOD
}

variable "tf_sa_token_lifetime_secs" {
  type        = number
  default     = 600
  description = <<EOD
The expiration duration for the service account token, in seconds. This value
should be high enough to prevent token timeout issues during resource creation,
but short enough that the token is useless replayed later. Default value is 600
(10 mins).
EOD
}

variable "project_id" {
  type        = string
  description = <<EOD
The GCP project identifier where the cluster will be created.
EOD
}

variable "prefix" {
  type        = string
  description = <<EOD
The prefix to apply to GCP resources created in this test run.
EOD
}

variable "region" {
  type        = string
  description = <<EOD
The compute region which will host the BIG-IP VMs.
EOD
}

variable "service_account" {
  type        = string
  description = <<EOD
The service account to use with BIG-IP.
EOD
}

variable "admin_password_secret_manager_key" {
  type        = string
  description = <<EOD
The Secret Manager key for BIG-IP admin password.
EOD
}

variable "alpha_net" {
  type        = string
  description = <<EOD
Self-link of alpha network.
EOD
}

variable "alpha_subnet" {
  type        = string
  description = <<EOD
Self-link of alpha subnet.
EOD
}

variable "beta_net" {
  type        = string
  description = <<EOD
Self-link of beta network.
EOD
}

variable "beta_subnet" {
  type        = string
  description = <<EOD
Self-link of beta subnet.
EOD
}

variable "gamma_net" {
  type        = string
  description = <<EOD
Self-link of gamma network.
EOD
}

variable "gamma_subnet" {
  type        = string
  description = <<EOD
Self-link of gamma subnet.
EOD
}

variable "delta_net" {
  type        = string
  description = <<EOD
Self-link of delta network.
EOD
}

variable "delta_subnet" {
  type        = string
  description = <<EOD
Self-link of delta subnet.
EOD
}

variable "epsilon_net" {
  type        = string
  description = <<EOD
Self-link of epsilon network.
EOD
}

variable "epsilon_subnet" {
  type        = string
  description = <<EOD
Self-link of epsilon subnet.
EOD
}

variable "zeta_net" {
  type        = string
  description = <<EOD
Self-link of zeta network.
EOD
}

variable "zeta_subnet" {
  type        = string
  description = <<EOD
Self-link of zeta subnet.
EOD
}

variable "eta_net" {
  type        = string
  description = <<EOD
Self-link of eta network.
EOD
}

variable "eta_subnet" {
  type        = string
  description = <<EOD
Self-link of eta subnet.
EOD
}

variable "theta_net" {
  type        = string
  description = <<EOD
Self-link of theta network.
EOD
}

variable "theta_subnet" {
  type        = string
  description = <<EOD
Self-link of theta subnet.
EOD
}

#
# The remaining inputs map 1:1 with the those of the example module; where the
# example has a default these will too of the same value. Objective is to make
# the harness behave like the example module unless overridden.
#

variable "num_instances" {
  type        = number
  default     = 1
  description = <<EOD
The number of BIG-IP instances to provision.
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
