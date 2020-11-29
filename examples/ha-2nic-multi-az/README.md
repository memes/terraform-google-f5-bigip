# High Availability sub-module with 2-NIC deployment in multiple availability zones

> You are viewing a **2.x release** of the modules, which supports
> **Terraform 0.13** only. *For modules compatible with Terraform 0.12, use a
> 1.x release.* Functionality is identical, but separate releases are required
> due to the difference in *variable validation* between Terraform 0.12 and 0.13.

This example demonstrates how to use the
[HA sub-module](https://registry.terraform.io/modules/memes/f5-bigip/google/latest/submodules/ha)
to deploy a pair of BIG-IP instances in a 2-NIC configuration, with instances in
two separate AZs.

> **NOTE:** This example does not include firewall rules, ingress routes, or any
> other dependencies needed to for a fully-functional deployment. The intent is
> only to demonstrate how to *add* an HA BIG-IP component to a broader
> deployment.

![ha-2nic](ha-2nic.png)

<!-- spell-checker: ignore tfvars gserviceaccount mgmt bigip -->
## Example tfvars file

* Deploy to project: `my-project-id`
* Deploy BIG-IPs to zone: `us-west1-b` and `us-west1-c`
* Assign BIG-IP data-plane to VPC: `external` in `us-west1` subnet `ext-west`
* Assign BIG-IP control-plane to VPC: `management` in `us-west1` subnet `mgmt-west`
* BIG-IP will use service account: `bigip@my-project-id.iam.gserviceaccount.com`
* BIG-IP admin user password is stored in Secret Manager under the key:
  `bigip-admin-password-key`

<!-- spell-checker: disable -->
```hcl
project_id         = "my-project-id"
zones              = ["us-west1-b", "us-west1-c"]
external_network   = "https://www.googleapis.com/compute/v1/projects/my-project-id/global/networks/external"
external_subnet    = "https://www.googleapis.com/compute/v1/projects/my-project-id/regions/us-west1/subnetworks/ext-west"
management_network = "https://www.googleapis.com/compute/v1/projects/my-project-id/global/networks/management"
management_subnet  = "https://www.googleapis.com/compute/v1/projects/my-project-id/regions/us-west1/subnetworks/mgmt-west"
admin_password_key = "bigip-admin-password-key"
service_account    = "bigip@my-project-id.iam.gserviceaccount.com"
```
<!-- spell-checker: enable -->

### Prerequisites

* VPC networks for `external`, and `management` with subnets in region where the
  BIG-IPs will be deployed
* Service account to be used by BIG-IP VMs
* BIG-IP admin account password stored in Secret Manager, with `read` access
  granted to BIG-IP service account

### Resources created

<!-- spell-checker: ignore payg -->
* 2x VMs running BIG-IP v15.1 PAYG license
  * 1 VM in `us-west1-b`
  * 1 VM in `us-west1-c`
* 2 reserved internal IP addresses on `external` VPC network; these will be
  assigned to external interface on BIG-IP instances
* 2 reserved internal IP addresses on `management` VPC network; these will be
  assigned to management interface on BIG-IP instances
* Firewall rules to permit BIG-IP ConfigSync traffic on `management` and
  `external` VPC networks, limited to VMs using BIG-IP service account

<!-- spell-checker:ignore markdownlint -->
<!-- markdownlint-disable MD033 MD034-->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.13.5 |

## Providers

| Name | Version |
|------|---------|
| google | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_password\_key | The Secret Manager key to lookup and retrive admin user password during<br>initialization. | `string` | n/a | yes |
| external\_network | The fully-qualified network self-link for the *external* network to which HA<br>firewall rules will be deployed. | `string` | n/a | yes |
| external\_subnet | The fully-qualified subnetwork self-link to attach to the BIG-IP VM \*external\*<br>interface. | `string` | n/a | yes |
| image | The BIG-IP image to use. Defaults to the latest v15 PAYG/good/5gbps<br>release as of the publishing of this module. | `string` | `"projects/f5-7626-networks-public/global/images/f5-bigip-15-0-1-3-0-0-4-payg-good-5gbps-200318182229"` | no |
| management\_network | The fully-qualified network self-link for the *management* network to which HA<br>firewall rules will be deployed. | `string` | n/a | yes |
| management\_subnet | The fully-qualified subnetwork self-link to attach to the BIG-IP VM \*management\*<br>interface. | `string` | n/a | yes |
| num\_instances | The number of BIG-IP instances to create. Default is 2. | `number` | `2` | no |
| project\_id | The GCP project identifier where the cluster will be created. | `string` | n/a | yes |
| service\_account | The service account to use for BIG-IP VMs. | `string` | n/a | yes |
| zones | A list of compute zones which will host the BIG-IP VMs. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| instance\_self\_links | Self-link of the BIG-IP instances. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
