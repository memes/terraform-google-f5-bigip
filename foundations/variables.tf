variable "tf_sa_email" {
  type        = string
  default     = ""
  description = <<EOD
The fully-qualified email address of the Terraform service account to use for
resource creation. E.g.
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
The GCP project identifier to use for testing foundations.
EOD
}

variable "prefix" {
  type        = string
  description = <<EOD
The prefix to apply to GCP resources.
EOD
}

variable "region" {
  type        = string
  description = <<EOD
The region to deploy resources.
EOD
}

variable "alpha_cidr" {
  type        = string
  default     = "172.16.0.0/16"
  description = <<EOD
The CIDR to apply to alpha subnet. Default is '172.16.0.0/16'.
EOD
}

variable "beta_cidr" {
  type        = string
  default     = "172.17.0.0/16"
  description = <<EOD
The CIDR to apply to beta subnet. Default is '172.17.0.0/16'.
EOD
}

variable "gamma_cidr" {
  type        = string
  default     = "172.18.0.0/16"
  description = <<EOD
The CIDR to apply to gamma subnet. Default is '172.18.0.0/16'.
EOD
}

variable "delta_cidr" {
  type        = string
  default     = "172.19.0.0/16"
  description = <<EOD
The CIDR to apply to delta subnet. Default is '172.19.0.0/16'.
EOD
}

variable "epsilon_cidr" {
  type        = string
  default     = "172.20.0.0/16"
  description = <<EOD
The CIDR to apply to epsilon subnet. Default is '172.20.0.0/16'.
EOD
}

variable "zeta_cidr" {
  type        = string
  default     = "172.21.0.0/16"
  description = <<EOD
The CIDR to apply to zeta subnet. Default is '172.21.0.0/16'.
EOD
}

variable "eta_cidr" {
  type        = string
  default     = "172.22.0.0/16"
  description = <<EOD
The CIDR to apply to eta subnet. Default is '172.22.0.0/16'.
EOD
}

variable "theta_cidr" {
  type        = string
  default     = "172.23.0.0/16"
  description = <<EOD
The CIDR to apply to theta subnet. Default is '172.23.0.0/16'.
EOD
}
