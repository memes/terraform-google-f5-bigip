# Standalone BIG-IP with 2-NIC deployment

This example demonstrates how to use the
[BIG-IP module](https://registry.terraform.io/modules/memes/f5-bigip/google/latest)
to deploy a single BIG-IP instance in a 2-NIC configuration.

> **NOTE:** This example does not include firewall rules, ingress routes, or any
> other dependencies needed to for a fully-functional deployment. The intent is
> only to demonstrate how to *add* a single BIG-IP component to a broader
> deployment.

![standalone-2nic](standalone-2nic.png)

<!-- spell-checker: ignore tfvars gserviceaccount mgmt bigip -->
## Example tfvars file

* Deploy to project: `my-project-id`
* Deploy BIG-IP to zone: `us-west1-c`
* Assign BIG-IP data-plane to VPC: `us-west1` subnet `ext-west`
* Assign BIG-IP control-plane to VPC: `us-west1` subnet `mgmt-west`
* BIG-IP will use service account: `bigip@my-project-id.iam.gserviceaccount.com`
* BIG-IP admin user password is stored in Secret Manager under the key:
  `bigip-admin-password-key`

<!-- spell-checker: disable -->
```hcl
project_id         = "my-project-id"
zone               = "us-west1-c"
external_subnet    = "https://www.googleapis.com/compute/v1/projects/my-project-id/regions/us-west1/subnetworks/ext-west"
management_subnet  = "https://www.googleapis.com/compute/v1/projects/my-project-id/regions/us-west1/subnetworks/mgmt-west"
admin_password_key = "bigip-admin-password-key"
service_account    = "bigip@my-project-id.iam.gserviceaccount.com"
```
<!-- spell-checker: enable -->

### Prerequisites

* VPC networks for `external`, and `management` with subnets in region where the
  BIG-IP will be deployed
* Service account to be used by BIG-IP VM
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
