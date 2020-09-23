# Foundations

This module is used to setup multiple networks for testing the published modules.
It is not needed for consumers of the modules.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12 |
| google | ~> 3.39 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.39 |
| random | n/a |

## Inputs

No input.

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
| theta\_west | theta us-west1 subnet self-link. |
| zeta\_west | zeta us-west1 subnet self-link. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
