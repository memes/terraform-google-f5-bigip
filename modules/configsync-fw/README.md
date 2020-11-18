# HA ConfigSync firewall sub-module

This Terraform module is a helper to create a pair of firewall rules that allow
ConfigSync traffic between BIG-IP instances on data-plane and control-plane
networks.

<!-- spell-checker: ignore dataplane -->
> **NOTE:** the module requires a management network self-link, and a
> *dataplane network* self-link. In a 2 NIC configuration, the dataplane network
> will be the one attached to NIC0 (typically described as the **external**
> network). In a 3 (or more) NIC deployment, BIG-IP will be configured to perform
> actions on *NIC2* (typically described as the first **internal** network). It
> is important to pass the correct value for `dataplane_network` in a 3+ NIC
> configuration or synchronisation between BIG-IP instances will be broken.

## Examples

### Create the ConfigSync firewall for 2-NIC BIG-IPs, with default firewall names

This example is suitable for an HA or CFE deployment of BIG-IPs with 2 NICs
defined.

<!-- spell-checker: disable -->
```hcl
module "configsync_fw" {
  source                = "memes/f5-bigip/google//modules/configsync-fw"
  version               = "1.2.2"
  project_id            = "my-project-id"
  bigip_service_account = "bigip@my-project-id.iam.gserviceaccount.com"
  dataplane_network     = "https://www.googleapis.com/compute/v1/projects/my-project-id/global/networks/external"
  management_network    = "https://www.googleapis.com/compute/v1/projects/my-project-id/global/networks/management"
}
```
<!-- spell-checker: enable -->

### Create the ConfigSync firewall for 3-NIC BIG-IPs, specify firewall names

This example is suitable for an HA or CFE deployment of BIG-IPs with 3+ NICs
defined, using the `internal` network for ConfigSync traffic on data-plane.

<!-- spell-checker: disable -->
```hcl
module "configsync_fw" {
  source                   = "memes/f5-bigip/google//modules/configsync-fw"
  version                  = "1.2.2"
  project_id               = "my-project-id"
  bigip_service_account    = "bigip@my-project-id.iam.gserviceaccount.com"
  dataplane_network        = "https://www.googleapis.com/compute/v1/projects/my-project-id/global/networks/internal"
  management_network       = "https://www.googleapis.com/compute/v1/projects/my-project-id/global/networks/management"
  dataplane_firewall_name  = "my-configsync-internal"
  management_firewall_name = "my-configsync-management"
}
```
<!-- spell-checker: enable -->

<!-- spell-checker:ignore markdownlint bigip -->
<!-- markdownlint-disable MD033 MD034 -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12.29 |
| google | >= 3.47 |

## Providers

| Name | Version |
|------|---------|
| google | >= 3.47 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bigip\_service\_account | The service account that will be used for the BIG-IP VMs; the firewall rules will<br>be constructed to use this for source and target filtering. | `string` | n/a | yes |
| dataplane\_firewall\_name | The name to use for data-plane network firewall rule. Default is<br>'allow-bigip-configsync-data-plane'. | `string` | `"allow-bigip-configsync-data-plane"` | no |
| dataplane\_network | The fully-qualified self-link of the subnet that will be used for data-plane<br>ConfigSync traffic. | `string` | n/a | yes |
| management\_firewall\_name | The name to use for Manangement (control-plane) network firewall rule. Default is<br>'allow-bigip-configsync-mgt'. | `string` | `"allow-bigip-configsync-mgt"` | no |
| management\_network | The fully-qualified self-link of the subnet that will be used for Management<br>(control-plane) ConfigSync traffic. | `string` | n/a | yes |
| project\_id | The GCP project identifier where the cluster will be created. | `string` | n/a | yes |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
