# CFE-Role sub-module

> You are viewing a **2.x release** of the modules, which supports
> **Terraform 0.13 and 0.14** only. *For modules compatible with Terraform 0.12,
> use a 1.x release.* Functionality is identical, but separate releases are
> required due to the difference in *variable validation* between Terraform 0.12
> and 0.13+.

This Terraform module is a helper to create a custom IAM role that has the
minimal permissions required for Cloud Failover Extension to function correctly.
The role will be created in the specified project by default, but can be created
as an *Organization role* if preferred, for reuse across projects.

Unless a specific identifier is provided in the `id` variable, a semi-random
identifier will be generated of the form `bigip_cfe_xxxxxxxxxx` to avoid unique
identifier collisions during the time after a custom role is deleted but before
it is purged from the project or organization.

> **NOTE:** This module is unsupported and not an official F5 product. If you
> require assistance please join our
> [Slack GCP channel](https://f5cloudsolutions.slack.com/messages/gcp) and ask!

## Examples

### Create the custom role at the project, and assign to a BIG-IP service account

<!-- spell-checker: disable -->
```hcl
module "cfe_role" {
  source    = "memes/f5-bigip/google//modules/cfe-role"
  version   = "2.0.2"
  target_id = "my-project-id"
  members   = ["serviceAccount:bigip@my-project-id.iam.gserviceaccount.com"]
}
```
<!-- spell-checker: enable -->

### Create the custom role for entire org, but do not explicitly assign membership

<!-- spell-checker: disable -->
```hcl
module "cfe_org_role" {
  source      = "memes/f5-bigip/google//modules/cfe-role"
  version     = "2.0.2"
  target_type = "org"
  target_id   = "my-org-id"
}
```
<!-- spell-checker: enable -->

### Create the custom role in the project with a fixed id, and assign to a BIG-IP service account

<!-- spell-checker: disable -->
```hcl
module "cfe_role" {
  source    = "memes/f5-bigip/google//modules/cfe-role"
  version   = "2.0.2"
  id = "my_custom_role"
  target_id = "my-project-id"
  members   = ["serviceAccount:bigip@my-project-id.iam.gserviceaccount.com"]
}
```
<!-- spell-checker: enable -->

<!-- spell-checker:ignore markdownlint bigip -->
<!-- markdownlint-disable MD033 MD034 -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | > 0.12 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.48 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cfe_role"></a> [cfe\_role](#module\_cfe\_role) | terraform-google-modules/iam/google//modules/custom_role_iam | 6.4.0 |

## Resources

| Name | Type |
|------|------|
| [random_id.role_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_target_id"></a> [target\_id](#input\_target\_id) | Sets the target for role creation; must be either an organization ID (target\_type = 'org'),<br>or project ID (target\_type = 'project'). | `string` | n/a | yes |
| <a name="input_id"></a> [id](#input\_id) | An identifier to use for the new role; default is an empty string which will<br>generate a unique identifier. If a value is provided, it must be unique at the<br>organization or project level depending on value of target\_type respectively.<br>E.g. multiple projects can all have a 'bigip\_cfe' role defined,<br>but an organization level role must be uniquely named. | `string` | `""` | no |
| <a name="input_members"></a> [members](#input\_members) | An optional list of accounts that will be assigned the custom role. Default is<br>an empty list. | `list(string)` | `[]` | no |
| <a name="input_target_type"></a> [target\_type](#input\_target\_type) | Determines if the CFE role is to be created for the whole organization ('org')<br>or at a 'project' level. Default is 'project'. | `string` | `"project"` | no |
| <a name="input_title"></a> [title](#input\_title) | The human-readable title to assign to the custom CFE role. Default is 'Custom BIG-IP CFE role'. | `string` | `"Custom BIG-IP CFE role"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_qualified_role_id"></a> [qualified\_role\_id](#output\_qualified\_role\_id) | The qualified role-id for the custom CFE role. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
