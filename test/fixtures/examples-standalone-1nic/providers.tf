
# This module makes use of service account impersonation to allow organization
# user accounts to act as the org-wide Terraform service account. This file
# defines the initialisation of google and google-beta providers that are acting
# as the named service account, assuming that the invoking user account has the
# permissions to create an authentication token for the service account.

# Instantiate a google provider aliased as 'executor'. This provider will use
# the calling user's credentials to authenticate to GCP APIs.
provider "google" {
  version = "~> 3.48"
  alias   = "executor"
}

# Force the use of google.executor for initial API client configurqtion.
data "google_client_config" "executor" {
  provider = google.executor
}

# Attempt to retrieve an authentication token for the named service account
# using the calling user's credentils.
# This will fail if the caller does not have IAM permissions on the target
# service account.
data "google_service_account_access_token" "sa_token" {
  count                  = coalesce(var.tf_sa_email, "undefined") != "undefined" ? 1 : 0
  provider               = google.executor
  target_service_account = var.tf_sa_email
  lifetime               = format("%ds", var.tf_sa_token_lifetime_secs)
  # Force scope to 'cloud-platform' so that IAM is solely responsible for permissions
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
  ]
}

# Instantiate unaliased google provider that is using the token associated with
# the target service account. This is the provider that will be used for
# resource creation.
provider "google" {
  version      = "~> 3.48"
  access_token = length(data.google_service_account_access_token.sa_token) == 1 ? element(data.google_service_account_access_token.sa_token, 0).access_token : null
}

# Instantiate unaliased google-beta provider that is using the token associated
# with the target service account. This is the provider that will be used for
# resource creation.
provider "google-beta" {
  version      = "~> 3.48"
  access_token = length(data.google_service_account_access_token.sa_token) == 1 ? element(data.google_service_account_access_token.sa_token, 0).access_token : null
}
