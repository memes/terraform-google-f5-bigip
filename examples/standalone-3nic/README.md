# Standalone BIG-IP with 3-NIC deployment

This example demonstrates how to use the
[BIG-IP module](https://registry.terraform.io/modules/memes/f5-bigip/google/latest)
to deploy a single BIG-IP instance in a 3-NIC configuration.

> **NOTE:** This example does not include firewall rules, ingress routes, or any
> other dependencies needed to for a fully-functional deployment. The intent is
> only to demonstrate how to *add* a single BIG-IP component to a broader
> deployment.

![standalone-3nic](standalone-3nic.png)

<!-- spell-checker: ignore tfvars gserviceaccount mgmt bigip -->
## Example tfvars file

* Deploy to project: `my-project-id`
* Deploy BIG-IPs to zone: `us-west1-c`
* Assign BIG-IP data-plane (external) to VPC: `us-west1` subnet `ext-west`
* Assign BIG-IP control-plane to VPC: `us-west1` subnet `mgmt-west`
* Assign BIG-IP data-plane (internal) to VPC: `us-west1` subnet `int-west`
* BIG-IP will use service account: `bigip@my-project-id.iam.gserviceaccount.com`
* BIG-IP admin user password is stored in Secret Manager under the key:
  `bigip-admin-password-key`

<!-- spell-checker: disable -->
```hcl
project_id         = "my-project-id"
zone               = "us-west1-c"
external_subnet    = "https://www.googleapis.com/compute/v1/projects/my-project-id/regions/us-west1/subnetworks/ext-west"
management_subnet  = "https://www.googleapis.com/compute/v1/projects/my-project-id/regions/us-west1/subnetworks/mgmt-west"
internal_subnet    = "https://www.googleapis.com/compute/v1/projects/my-project-id/regions/us-west1/subnetworks/int-west"
admin_password_key = "bigip-admin-password-key"
service_account    = "bigip@my-project-id.iam.gserviceaccount.com"
```
<!-- spell-checker: enable -->

### Prerequisites

* VPC networks for `external`, `management`, and `internal` with subnets in
  region where the BIG-IPs will be deployed
* Service account to be used by BIG-IP VMs
* BIG-IP admin account password stored in Secret Manager, with `read` access
  granted to BIG-IP service account

### Resources created

<!-- spell-checker: ignore payg -->
* 1x VM running BIG-IP v15.1 PAYG license

<!-- spell-checker:ignore markdownlint -->
<!-- markdownlint-disable MD033 MD034-->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
