# Standalone BIG-IP (4-NIC) with external and internal VIPs

> You are viewing a **1.x release** of the modules, which supports
> **Terraform 0.12** only. *For modules compatible with Terraform 0.13 and 0.14,
> use a 2.x release.* Functionality is identical, but separate releases are required
> due to the difference in *variable validation* between Terraform 0.12 and 0.13+.

This example demonstrates how to use the
[BIG-IP module](https://registry.terraform.io/modules/memes/f5-bigip/google/latest)
to deploy multiple BIG-IP instance in a 4-NIC configuration, with VIPs (Alias IPs)
assigned to external and internal networks.

> **NOTE:** This example does not include firewall rules, ingress routes, or any
> other dependencies needed to for a fully-functional deployment. The intent is
> only to demonstrate how to *add* a single BIG-IP component to a broader
> deployment.

![standalone-4nic](standalone-4nic.png)

<!-- spell-checker: ignore tfvars gserviceaccount mgmt bigip -->
## Example tfvars file

* Deploy to project: `my-project-id`
* Deploy BIG-IP to zone: `us-west1-c`
* Assign BIG-IP data-plane (external) to VPC: `us-west1` subnet `ext-west`
* Assign BIG-IP control-plane to VPC: `us-west1` subnet `mgmt-west`
* Assign BIG-IP data-planes (first internal) to VPCs: `us-west1` subnet `int-west`
* Assign BIG-IP data-planes (second internal) to VPCs: `us-west1` subnet `int1-west`
* BIG-IP will use service account: `bigip@my-project-id.iam.gserviceaccount.com`
* BIG-IP admin user password is stored in Secret Manager under the key:
  `bigip-admin-password-key`
* VIPS:
  * 1x /30 on each instance external interface
  * 1x /31 on first instance's second internal interface
  * 2x /31 on second instance's first and second internal interface

<!-- spell-checker: disable -->
```hcl
project_id         = "my-project-id"
num_instances      = 2
zone               = "us-west1-c"
external_subnet    = "https://www.googleapis.com/compute/v1/projects/my-project-id/regions/us-west1/subnetworks/ext-west"
management_subnet  = "https://www.googleapis.com/compute/v1/projects/my-project-id/regions/us-west1/subnetworks/mgmt-west"
internal_subnets   = [
    "https://www.googleapis.com/compute/v1/projects/my-project-id/regions/us-west1/subnetworks/int-west",
    "https://www.googleapis.com/compute/v1/projects/my-project-id/regions/us-west1/subnetworks/int1-west",
]
admin_password_key = "bigip-admin-password-key"
service_account    = "bigip@my-project-id.iam.gserviceaccount.com"
external_vips      = [
    ["172.16.1.8/30"],  # first instance
    ["172.16.1.12/30"], # second instance
]
internal_vips      = [
    # first instance
    [
        [], # No VIP on first internal nic
        ["172.19.1.4/31"], # assign on second internal nic
    ],
    # second instance
    [
        ["172.18.1.8/31"], # assign on first internal nic
        ["172.19.1.8/31"], # assign on second internal nic
    ],
]
```
<!-- spell-checker: enable -->

### Prerequisites

* VPC networks for `external`, `management`, `internal`, and `internal1` with
  subnets in region where the BIG-IPs will be deployed
* Service account to be used by BIG-IP VMs
* BIG-IP admin account password stored in Secret Manager, with `read` access
  granted to BIG-IP service account

### Resources created

<!-- spell-checker: ignore payg -->
* 2x VM running BIG-IP v15.1 PAYG license

<!-- spell-checker:ignore markdownlint -->
<!-- markdownlint-disable MD033 MD034-->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 0.12.28, < 0.13 |

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
| <a name="input_admin_password_key"></a> [admin\_password\_key](#input\_admin\_password\_key) | The Secret Manager key to lookup and retrive admin user password during<br>initialization. | `string` | n/a | yes |
| <a name="input_external_subnet"></a> [external\_subnet](#input\_external\_subnet) | The fully-qualified subnetwork self-link to attach to the BIG-IP VM *external*<br>interface. | `string` | n/a | yes |
| <a name="input_external_vips"></a> [external\_vips](#input\_external\_vips) | A list of list of CIDRs to apply to each instance as an Alias IP (VIP). | `list(list(string))` | n/a | yes |
| <a name="input_instance_name_template"></a> [instance\_name\_template](#input\_instance\_name\_template) | A format string that will be used when naming instance, that should include a<br>format token for including ordinal number. E.g. 'bigip-%d', such that %d will<br>be replaced with the ordinal of each instance. | `string` | n/a | yes |
| <a name="input_internal_subnets"></a> [internal\_subnets](#input\_internal\_subnets) | The list of fully-qualified subnetwork self-links to attach to the BIG-IP VM<br>*internal* interfaces. | `list(string)` | n/a | yes |
| <a name="input_internal_vips"></a> [internal\_vips](#input\_internal\_vips) | A list of list of list of CIDRs to apply to each instance as an Alias IP (VIP). | `list(list(list(string)))` | n/a | yes |
| <a name="input_management_subnet"></a> [management\_subnet](#input\_management\_subnet) | The fully-qualified subnetwork self-link to attach to the BIG-IP VM *management*<br>interface. | `string` | n/a | yes |
| <a name="input_num_instances"></a> [num\_instances](#input\_num\_instances) | The number of BIG-IP instances to create. | `number` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project identifier where the cluster will be created. | `string` | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | The service account to use for BIG-IP VMs. | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | The compute zone which will host the BIG-IP VMs. | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | The BIG-IP image to use. Defaults to the latest v15 PAYG/good/5gbps<br>release as of the publishing of this module. | `string` | `"projects/f5-7626-networks-public/global/images/f5-bigip-15-1-2-1-0-0-10-payg-good-5gbps-210115160742"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_self_links"></a> [instance\_self\_links](#output\_instance\_self\_links) | Self-link of the BIG-IP instances. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
