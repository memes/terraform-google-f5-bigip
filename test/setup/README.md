# Test Setup

This module is used to setup multiple VPC networks, NATs, etc., for testing the
published modules.

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
| google.executor | ~> 3.48 ~> 3.48 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| prefix | The prefix to apply to GCP resources created in this test run. | `string` | n/a | yes |
| project\_id | The GCP project identifier to use for testing. | `string` | n/a | yes |
| region | The region to deploy test resources. Default is 'us-west1'. | `string` | `"us-west1"` | no |
| tf\_sa\_email | The fully-qualified email address of the Terraform service account to use for<br>resource creation via account impersonation. If left blank, the default, then<br>the invoker's account will be used.<br><br>E.g. if you have permissions to impersonate:<br><br>tf\_sa\_email = "terraform@PROJECT\_ID.iam.gserviceaccount.com" | `string` | `""` | no |
| tf\_sa\_token\_lifetime\_secs | The expiration duration for the service account token, in seconds. This value<br>should be high enough to prevent token timeout issues during resource creation,<br>but short enough that the token is useless replayed later. Default value is 600<br>(10 mins). | `number` | `600` | no |

## Outputs

| Name | Description |
|------|-------------|
| alpha\_net | Self-link of the alpha network. |
| alpha\_subnet | Self-link of the alpha subnet. |
| beta\_net | Self-link of the beta network. |
| beta\_subnet | Self-link of the beta subnet. |
| delta\_net | Self-link of the delta network. |
| delta\_subnet | Self-link of the delta subnet. |
| epsilon\_subnet | Self-link of the epsilon subnet. |
| epsion\_net | Self-link of the epsilon network. |
| eta | Self-link of the eta subnet. |
| eta\_net | Self-link of the eta network. |
| gamma\_net | Self-link of the gamma network. |
| gamma\_subnet | Self-link of the gamma subnet. |
| sa | The fully-qualified service account email to use with BIG-IP instances. |
| secret\_id | The project-local secret id containing the generated BIG-IP admin password. |
| theta\_net | Self-link of the theta network. |
| theta\_subnet | Self-link of the theta subnet. |
| zeta\_net | Self-link of the zeta network. |
| zeta\_subnet | Self-link of the zeta subnet. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
