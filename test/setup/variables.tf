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
The GCP project identifier to use for testing.
EOD
}

variable "regions" {
  type        = list(string)
  default     = ["us-west1", "us-central1", "us-east1", "us-west2"]
  description = <<EOD
The regions to deploy test resources. Default is ["us-west1", "us-central1",
"us-east1", "us-west2"].
EOD
}

variable "admin_source_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = <<EOD
The list of source CIDRs that will be added to firewall rules to allow admin
access to BIG-IPs (SSH and GUI) on alpha and beta subnetworks. Only useful if
instance has a public IP address.
EOD
}
