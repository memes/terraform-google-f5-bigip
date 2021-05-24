# Test Setup

This module is used to setup multiple VPC networks, NATs, etc., for testing the
published modules.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | > 0.12 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 3.58 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 3.58 |
| <a name="provider_google.executor"></a> [google.executor](#provider\_google.executor) | ~> 3.58 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alpha"></a> [alpha](#module\_alpha) | terraform-google-modules/network/google | 3.0.0 |
| <a name="module_alpha-nat"></a> [alpha-nat](#module\_alpha-nat) | terraform-google-modules/cloud-nat/google | ~> 1.3.0 |
| <a name="module_beta"></a> [beta](#module\_beta) | terraform-google-modules/network/google | 3.0.0 |
| <a name="module_beta-nat"></a> [beta-nat](#module\_beta-nat) | terraform-google-modules/cloud-nat/google | ~> 1.3.0 |
| <a name="module_bigip_sa"></a> [bigip\_sa](#module\_bigip\_sa) | terraform-google-modules/service-accounts/google | 3.0.1 |
| <a name="module_delta"></a> [delta](#module\_delta) | terraform-google-modules/network/google | 3.0.0 |
| <a name="module_epsilon"></a> [epsilon](#module\_epsilon) | terraform-google-modules/network/google | 3.0.0 |
| <a name="module_eta"></a> [eta](#module\_eta) | terraform-google-modules/network/google | 3.0.0 |
| <a name="module_gamma"></a> [gamma](#module\_gamma) | terraform-google-modules/network/google | 3.0.0 |
| <a name="module_inspec_sa"></a> [inspec\_sa](#module\_inspec\_sa) | terraform-google-modules/service-accounts/google | 3.0.1 |
| <a name="module_password"></a> [password](#module\_password) | memes/secret-manager/google//modules/random | 1.0.2 |
| <a name="module_theta"></a> [theta](#module\_theta) | terraform-google-modules/network/google | 3.0.0 |
| <a name="module_zeta"></a> [zeta](#module\_zeta) | terraform-google-modules/network/google | 3.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.admin_alpha](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.admin_beta](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [local_file.harness_tfvars](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.inspec_json](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_id.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [google_client_config.executor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_service_account_access_token.sa_token](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account_access_token) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project identifier to use for testing. | `string` | n/a | yes |
| <a name="input_admin_source_cidrs"></a> [admin\_source\_cidrs](#input\_admin\_source\_cidrs) | The list of source CIDRs that will be added to firewall rules to allow admin<br>access to BIG-IPs (SSH and GUI) on alpha and beta subnetworks. Only useful if<br>instance has a public IP address. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_regions"></a> [regions](#input\_regions) | The regions to deploy test resources. Default is ["us-west1", "us-central1",<br>"us-east1", "us-west2"]. | `list(string)` | <pre>[<br>  "us-west1",<br>  "us-central1",<br>  "us-east1",<br>  "us-west2"<br>]</pre> | no |
| <a name="input_tf_sa_email"></a> [tf\_sa\_email](#input\_tf\_sa\_email) | The fully-qualified email address of the Terraform service account to use for<br>resource creation via account impersonation. If left blank, the default, then<br>the invoker's account will be used.<br><br>E.g. if you have permissions to impersonate:<br><br>tf\_sa\_email = "terraform@PROJECT\_ID.iam.gserviceaccount.com" | `string` | `""` | no |
| <a name="input_tf_sa_token_lifetime_secs"></a> [tf\_sa\_token\_lifetime\_secs](#input\_tf\_sa\_token\_lifetime\_secs) | The expiration duration for the service account token, in seconds. This value<br>should be high enough to prevent token timeout issues during resource creation,<br>but short enough that the token is useless replayed later. Default value is 600<br>(10 mins). | `number` | `600` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
