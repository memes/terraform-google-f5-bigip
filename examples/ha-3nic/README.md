# High Availability sub-module with 3-NIC deployment

> You are viewing a **1.x release** of the modules, which supports
> **Terraform 0.12** only. *For modules compatible with Terraform 0.13, use a
> 2.x release.* Functionality is identical, but separate releases are required
> due to the difference in *variable validation* between Terraform 0.12 and 0.13.

This example demonstrates how to use the
[HA sub-module](https://registry.terraform.io/modules/memes/f5-bigip/google/latest/submodules/ha)
to deploy a pair of BIG-IP instances in a 3-NIC configuration.

> **NOTE:** This example does not include firewall rules, ingress routes, or any
> other dependencies needed to for a fully-functional deployment. The intent is
> only to demonstrate how to *add* an HA BIG-IP component to a broader
> deployment.

![ha-3nic](ha-3nic.png)

<!-- spell-checker: ignore tfvars gserviceaccount mgmt bigip -->
## Example tfvars file

* Deploy to project: `my-project-id`
* Deploy BIG-IPs to zone: `us-west1-c`
* Assign BIG-IP data-plane (external) to VPC: `external` in `us-west1` subnet `ext-west`
* Assign BIG-IP control-plane to VPC: `management` in `us-west1` subnet `mgmt-west`
* Assign BIG-IP data-plane (internal) to VPC: `internal` in `us-west1` subnet `int-west`
* BIG-IP will use service account: `bigip@my-project-id.iam.gserviceaccount.com`
* BIG-IP admin user password is stored in Secret Manager under the key:
  `bigip-admin-password-key`

<!-- spell-checker: disable -->
```hcl
project_id         = "my-project-id"
zone               = "us-west1-c"
external_network   = "https://www.googleapis.com/compute/v1/projects/my-project-id/global/networks/external"
external_subnet    = "https://www.googleapis.com/compute/v1/projects/my-project-id/regions/us-west1/subnetworks/ext-west"
management_network = "https://www.googleapis.com/compute/v1/projects/my-project-id/global/networks/management"
management_subnet  = "https://www.googleapis.com/compute/v1/projects/my-project-id/regions/us-west1/subnetworks/mgmt-west"
internal_network   = "https://www.googleapis.com/compute/v1/projects/my-project-id/global/networks/internal"
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
* 2x VMs running BIG-IP v15.1 PAYG license
* 2 reserved internal IP addresses on `external` VPC network; these will be
  assigned to external interface on BIG-IP instances
* 2 reserved internal IP addresses on `management` VPC network; these will be
  assigned to management interface on BIG-IP instances
* 2 reserved internal IP addresses on `internal` VPC network; these will be
  assigned to internal interface on BIG-IP instances
* Firewall rules to permit BIG-IP ConfigSync traffic on `management` and
  `external` VPC networks, limited to VMs using BIG-IP service account

<!-- spell-checker:ignore markdownlint -->
<!-- markdownlint-disable MD033 MD034-->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 0.12.28, < 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ha"></a> [ha](#module\_ha) | ../../modules/ha/ |  |
| <a name="module_ha_fw"></a> [ha\_fw](#module\_ha\_fw) | ../../modules/configsync-fw/ |  |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.ext](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.int](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.mgt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password_key"></a> [admin\_password\_key](#input\_admin\_password\_key) | The Secret Manager key to lookup and retrive admin user password during<br>initialization. | `string` | n/a | yes |
| <a name="input_external_subnet"></a> [external\_subnet](#input\_external\_subnet) | The fully-qualified subnetwork self-link to attach to the BIG-IP VM *external*<br>interface. | `string` | n/a | yes |
| <a name="input_internal_network"></a> [internal\_network](#input\_internal\_network) | The fully-qualified network self-link for the *internal* network to which HA<br>firewall rules will be deployed. | `string` | n/a | yes |
| <a name="input_internal_subnet"></a> [internal\_subnet](#input\_internal\_subnet) | The fully-qualified subnetwork self-link to attach to the BIG-IP VM *internal*<br>interface. | `string` | n/a | yes |
| <a name="input_management_network"></a> [management\_network](#input\_management\_network) | The fully-qualified network self-link for the *management* network to which HA<br>firewall rules will be deployed. | `string` | n/a | yes |
| <a name="input_management_subnet"></a> [management\_subnet](#input\_management\_subnet) | The fully-qualified subnetwork self-link to attach to the BIG-IP VM *management*<br>interface. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project identifier where the cluster will be created. | `string` | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | The service account to use for BIG-IP VMs. | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | The compute zone which will host the BIG-IP VMs. | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | The BIG-IP image to use. Defaults to the latest v15 PAYG/good/5gbps<br>release as of the publishing of this module. | `string` | `"projects/f5-7626-networks-public/global/images/f5-bigip-15-1-2-1-0-0-10-payg-good-5gbps-210115160742"` | no |
| <a name="input_num_instances"></a> [num\_instances](#input\_num\_instances) | The number of BIG-IP instances to create. Default is 2. | `number` | `2` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instances_self_link"></a> [instances\_self\_link](#output\_instances\_self\_link) | Self-link of the BIG-IP instances. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
