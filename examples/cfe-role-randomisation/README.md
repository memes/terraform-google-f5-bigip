# Cloud Failover Extension custom role sub-module

> You are viewing a **2.x release** of the modules, which supports
> **Terraform 0.13 and 0.14** only. *For modules compatible with Terraform 0.12,
> use a 1.x release.* Functionality is identical, but separate releases are
> required due to the difference in *variable validation* between Terraform 0.12
> and 0.13+.

This example demonstrates how to create an IAM custom role for BIG-IP CFE using
[cfe-role](https://registry.terraform.io/modules/memes/f5-bigip/google/latest/submodules/cfe-role)
.

> **NOTE:** This example does not include firewall rules, ingress routes, or any
> other dependencies needed to for a fully-functional deployment. The intent is
> only to demonstrate how to *add* a CFE-based BIG-IP component to a broader
> deployment.

<!-- spell-checker: ignore tfvars gserviceaccount mgmt bigip -->
## Example tfvars file

* Deploy to project: `my-project-id`
* Allow module to randomise custom role ID: yes
* Assign role to BIG-IP service account: `bigip@my-project-id.iam.gserviceaccount.com`

<!-- spell-checker: disable -->
```hcl
project_id = "my-project-id"
# Set id to empty string to auto-generate a semi-random id
id         = ""
members    = ["serviceAccount:bigip@my-project-id.iam.gserviceaccount.com"]
```
<!-- spell-checker: enable -->

### Prerequisites

* Service account to be used by BIG-IP VMs

### Resources created

<!-- spell-checker: ignore payg -->
* 1x Custom IAM role assigned to the project

<!-- spell-checker:ignore markdownlint -->
<!-- markdownlint-disable MD033 MD034-->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12.28, < 0.13 |

## Providers

No provider.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| id | An identifier to use for the new role; default is an empty string which will<br>generate a unique identifier. If a value is provided, it must be unique at the<br>organization or project level depending on value of target\_type respectively.<br>E.g. multiple projects can all have a 'bigip\_cfe' role defined,<br>but an organization level role must be uniquely named. | `string` | `""` | no |
| members | An optional list of accounts that will be assigned the custom role. Default is<br>an empty list. | `list(string)` | `[]` | no |
| project\_id | The GCP project identifier where the cluster will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| qualified\_role\_id | The qualified role-id for the custom CFE role. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
