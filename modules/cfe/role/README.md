# CFE-Role sub-module

This Terraform module is a helper to create a custom IAM role that has the
permissions required for correct Cloud Failover Extension to function correctly.

<!-- spell-checker:ignore markdownlint bigip -->
<!-- markdownlint-disable MD033 MD034 -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12 |
| google | >= 3.40 |

## Providers

No provider.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| id | An identifier to use for the new role; default is 'bigip\_cfe'. This id must<br>be unique at the organization or project level depending on value of target\_type<br>respectively. E.g. multiple projects can all have a 'bigip\_cfe' role defined,<br>but an organization level role must be uniquely named. | `string` | `"bigip_cfe"` | no |
| members | An optional list of accounts that will be assigned the custom role. Default is<br>an empty list. | `list(string)` | `[]` | no |
| target\_id | Sets the target for role creation; must be either an organization ID (target\_type = 'org'),<br>or project ID (target\_type = 'project'). | `string` | n/a | yes |
| target\_type | Determines if the CFE role is to be created for the whole organization ('org')<br>or at a 'project' level. Default is 'project'. | `string` | `"project"` | no |
| title | The human-readable title to assign to the custom CFE role. Default is 'Custom BIG-IP CFE role'. | `string` | `"Custom BIG-IP CFE role"` | no |

## Outputs

| Name | Description |
|------|-------------|
| qualified\_role\_id | The qualified role-id for the custom CFE role. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
