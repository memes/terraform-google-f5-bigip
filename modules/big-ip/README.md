# BIG-IP modules

<!-- spell-checker:ignore markdownlint, NICs, secretmanager -->
These modules support deploying BIG-IP v13, v14, and v15 instances to Google Cloud
in an opinionated manner. By themselves they do not implement a full stack or
solution, and additional setup will be needed for firewall rules, service account
creation and role assignments.

## Dependencies

The BIG-IP modules all have a common set of requirements.

1. Terraform 0.12

   A future version of these modules will target Terraform 0.13 once the majority
   of module consumers request it.

2. Google Cloud [Secret Manager](https://cloud.google.com/secret-manager)

   There are many good options for run-time secret injection but this module is
   supporting Google's Secret Manager only at this time.

3. APIs to enable

   * Compute Engine `compute.googleapis.com`
   * Secret Manager `secretmanager.googleapis.com`
   * Storage (required for CFE) `storage-api.googleapis.com`

## Run-time setup

The BIG-IP modules in this repo support [cloud-init](https://cloudinit.readthedocs.io/en/latest/)
and [metadata-startup-script](https://cloud.google.com/compute/docs/startupscript)
boot options, defaulting to the metadata startup-script for compatibility with
BIG-IP versions 13.x, 14.x, and 15.x. Set the `use_cloud_init` input variable to
`true`.

Fundamentally both approaches launch the same shell scripts; the difference is
that `cloud-init` script installs a systemd service unit with dependencies to
prevent early execution, and automatically disables the service unit after
success. The simple metadata startup-script will execute on every boot.

For more information on how run-time configuration is applied to each BIG-IP
instance, see the [configuration details](metadata#configuration) section in [metadata module](metadata).
