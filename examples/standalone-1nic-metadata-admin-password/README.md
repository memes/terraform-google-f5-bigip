# Standalone BIG-IP (single NIC) deployment that uses a value in VM metadata to set BIG-IP admin password

**THIS EXAMPLE SETS THE ADMIN PASSWORD FROM A CLEARTEXT VALUE VISIBLE TO ANYONE
WITH ACCESS TO INSTANCE METADATA!**

> You are viewing a **2.x release** of the modules, which supports
> **Terraform 0.13 and 0.14** only. *For modules compatible with Terraform 0.12,
> use a 1.x release.* Functionality is identical, but separate releases are
> required due to the difference in *variable validation* between Terraform 0.12
> and 0.13+.

This example demonstrates how to use the
[BIG-IP module](https://registry.terraform.io/modules/memes/f5-bigip/google/latest)
to deploy a single BIG-IP instance without using a secure method to retrieve admin
password at runtime. By adding a cleartext password as a metadata value, BIG-IP
can be configured even if you are not using a secret method known to the modules.
This is almost certainly NOT a good idea for anything other than a toy deployment.
Open an issue to request support for a third-party secret manager if not currently
implemented in module.

> **NOTE:** This example does not include firewall rules, ingress routes, or any
> other dependencies needed to for a fully-functional deployment. The intent is
> only to demonstrate how to *add* a single BIG-IP component to a broader
> deployment.

![standalone-1nic](standalone-1nic.png)

<!-- spell-checker: ignore tfvars gserviceaccount mgmt bigip -->
## Example tfvars file

* Deploy to project: `my-project-id`
* Deploy BIG-IPs to zone: `us-west1-c`
* Assign BIG-IP to VPC: `us-west1` subnet `ext-west`
* BIG-IP will use service account: `bigip@my-project-id.iam.gserviceaccount.com`
* BIG-IP admin user password is stored in cleartext in metadata using the key:
  `bigip-admin-password`

<!-- spell-checker: disable -->
```hcl
project_id            = "my-project-id"
zone                  = "us-west1-c"
subnet                = "https://www.googleapis.com/compute/v1/projects/my-project-id/regions/us-west1/subnetworks/ext-west"
service_account       = "bigip@my-project-id.iam.gserviceaccount.com"
secret_implementor    = "metadata"
# This value must match the metadata key containing the actual password
admin_password_key    = "bigip-admin-password"
metadata = {
    bigip-admin-password = "Sup3rS3cret#"
}
```
<!-- spell-checker: enable -->

### Prerequisites

* VPC networks for `external` with subnet in
  region where the BIG-IP will be deployed
* Service account to be used by BIG-IP VM
* BIG-IP admin account password stored in Secret Manager, with `read` access
  granted to BIG-IP service account

### Resources created

<!-- spell-checker: ignore payg -->
* 1x VM running BIG-IP v15.1 PAYG license

<!-- spell-checker:ignore markdownlint -->
<!-- markdownlint-disable MD033 MD034-->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | > 0.12 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_instance"></a> [instance](#module\_instance) | ../../ |  |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password_key"></a> [admin\_password\_key](#input\_admin\_password\_key) | The metadata key to lookup and retrive admin user password during initialization. | `string` | n/a | yes |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | Additional metadata values to pass to instances. For the demo that should include<br>an admin user password in cleartext associated with the key whose value matches<br>`admin_pasword_key`. | `map(string)` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project identifier where the cluster will be created. | `string` | n/a | yes |
| <a name="input_secret_implementor"></a> [secret\_implementor](#input\_secret\_implementor) | The implementation to use for secret retrieval. | `string` | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | The service account to use for BIG-IP VMs. | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | The fully-qualified subnetwork self-link to attach to the BIG-IP VM. | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | The compute zone which will host the BIG-IP VMs. | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | The BIG-IP image to use. Defaults to the latest v15 PAYG/good/5gbps<br>release as of the publishing of this module. | `string` | `"projects/f5-7626-networks-public/global/images/f5-bigip-15-1-2-1-0-0-10-payg-good-5gbps-210115160742"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_self_link"></a> [instance\_self\_link](#output\_instance\_self\_link) | Self-link of the BIG-IP instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
