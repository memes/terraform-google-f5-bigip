# Foundations

This module is used to setup multiple VPC networks, NATs, etc., for testing the
published modules. It is not needed for consumers of the modules, but included
for visibility.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | > 0.11 |
| google | ~> 3.48 |
| google | ~> 3.48 |
| google-beta | ~> 3.48 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.48 ~> 3.48 |
| google.executor | ~> 3.48 ~> 3.48 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| alpha | git::https://github.com/memes/terraform-google-network?ref=memes/vpc_mtu |  |
| alpha-nat | terraform-google-modules/cloud-nat/google | ~> 1.3.0 |
| bastion | terraform-google-modules/bastion-host/google | 2.10.0 |
| beta | git::https://github.com/memes/terraform-google-network?ref=memes/vpc_mtu |  |
| beta-nat | terraform-google-modules/cloud-nat/google | ~> 1.3.0 |
| bigip_password | memes/secret-manager/google//modules/random | 1.0.2 |
| delta | git::https://github.com/memes/terraform-google-network?ref=memes/vpc_mtu |  |
| epsilon | git::https://github.com/memes/terraform-google-network?ref=memes/vpc_mtu |  |
| eta | git::https://github.com/memes/terraform-google-network?ref=memes/vpc_mtu |  |
| gamma | git::https://github.com/memes/terraform-google-network?ref=memes/vpc_mtu |  |
| googleapis | terraform-google-modules/cloud-dns/google | 3.0.2 |
| service_accounts | terraform-google-modules/service-accounts/google | 3.0.1 |
| theta | git::https://github.com/memes/terraform-google-network?ref=memes/vpc_mtu |  |
| zeta | git::https://github.com/memes/terraform-google-network?ref=memes/vpc_mtu |  |

## Resources

| Name |
|------|
| [google_client_config](https://registry.terraform.io/providers/hashicorp/google/3.48/docs/data-sources/client_config) |
| [google_compute_firewall](https://registry.terraform.io/providers/hashicorp/google/3.48/docs/resources/compute_firewall) |
| [google_service_account_access_token](https://registry.terraform.io/providers/hashicorp/google/3.48/docs/data-sources/service_account_access_token) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| prefix | The prefix to apply to GCP resources. | `string` | n/a | yes |
| project\_id | The GCP project identifier to use for testing foundations. | `string` | n/a | yes |
| region | The region to deploy resources. | `string` | n/a | yes |
| alpha\_cidr | The CIDR to apply to alpha subnet. Default is '172.16.0.0/16'. | `string` | `"172.16.0.0/16"` | no |
| alpha\_mtu | The MTU to set on the alpha network. Default is 1460. | `number` | `1460` | no |
| beta\_cidr | The CIDR to apply to beta subnet. Default is '172.17.0.0/16'. | `string` | `"172.17.0.0/16"` | no |
| beta\_mtu | The MTU to set on the beta network. Default is 1460. | `number` | `1460` | no |
| delta\_cidr | The CIDR to apply to delta subnet. Default is '172.19.0.0/16'. | `string` | `"172.19.0.0/16"` | no |
| delta\_mtu | The MTU to set on the delta network. Default is 1460. | `number` | `1500` | no |
| epsilon\_cidr | The CIDR to apply to epsilon subnet. Default is '172.20.0.0/16'. | `string` | `"172.20.0.0/16"` | no |
| epsilon\_mtu | The MTU to set on the epsilon network. Default is 1460. | `number` | `1500` | no |
| eta\_cidr | The CIDR to apply to eta subnet. Default is '172.22.0.0/16'. | `string` | `"172.22.0.0/16"` | no |
| eta\_mtu | The MTU to set on the eta network. Default is 1500. | `number` | `1500` | no |
| gamma\_cidr | The CIDR to apply to gamma subnet. Default is '172.18.0.0/16'. | `string` | `"172.18.0.0/16"` | no |
| gamma\_mtu | The MTU to set on the gamma network. Default is 1460. | `number` | `1460` | no |
| tf\_sa\_email | The fully-qualified email address of the Terraform service account to use for<br>resource creation. E.g.<br>tf\_sa\_email = "terraform@PROJECT\_ID.iam.gserviceaccount.com" | `string` | `""` | no |
| tf\_sa\_token\_lifetime\_secs | The expiration duration for the service account token, in seconds. This value<br>should be high enough to prevent token timeout issues during resource creation,<br>but short enough that the token is useless replayed later. Default value is 600<br>(10 mins). | `number` | `600` | no |
| theta\_cidr | The CIDR to apply to theta subnet. Default is '172.23.0.0/16'. | `string` | `"172.23.0.0/16"` | no |
| theta\_mtu | The MTU to set on the theta network. Default is 1500. | `number` | `1500` | no |
| zeta\_cidr | The CIDR to apply to zeta subnet. Default is '172.21.0.0/16'. | `string` | `"172.21.0.0/16"` | no |
| zeta\_mtu | The MTU to set on the zeta network. Default is 1460. | `number` | `1500` | no |

## Outputs

| Name | Description |
|------|-------------|
| alpha\_west | Alpha us-west1 subnet self-link. |
| bastion\_name | The name of the bastion VM. |
| beta\_west | beta us-west1 subnet self-link. |
| bigip\_sa | The fully-qualified service account email to use with BIG-IP instances. |
| delta\_west | delta us-west1 subnet self-link. |
| epsilon\_west | epsilon us-west1 subnet self-link. |
| eta\_west | eta us-west1 subnet self-link. |
| gamma\_west | gamma us-west1 subnet self-link. |
| service\_sa | The fully-qualified service account email to use with backend service instances. |
| theta\_west | theta us-west1 subnet self-link. |
| zeta\_west | zeta us-west1 subnet self-link. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
