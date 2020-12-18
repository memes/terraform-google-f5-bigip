# BIG-IP metadata module

> You are viewing a **2.x release** of the modules, which supports
> **Terraform 0.13 and 0.14** only. *For modules compatible with Terraform 0.12,
> use a 1.x release.* Functionality is identical, but separate releases are
> required due to the difference in *variable validation* between Terraform 0.12
> and 0.13+.

This module encapsulates the creation of a set of metadata entries common to
BIG-IP Terraform modules as used in this repo. Embedding the required files and
configuration options allows the various modules to override entries and customise
for specific needs.

This module does not create any GCP or other resources; it's sole output is a map
of key:value entries that include run-time initialisation through `cloud-init`
or a shell startup-script (the default for compatibility reasons) that will be
consumed by higher-order BIG-IP deployment modules.

> **NOTE:** This module is unsupported and not an official F5 product. If you
> require assistance please join our
> [Slack GCP channel](https://f5cloudsolutions.slack.com/messages/gcp) and ask!

<!-- spell-checker:ignore markdownlint hostnames byol payg zoneinfo -->
<!-- markdownlint-disable MD033 MD034 -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | > 0.12 |

## Providers

No provider.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_password\_secret\_manager\_key | The Secret Manager key for BIG-IP admin password; during initialisation, the<br>BIG-IP admin account's password will be changed to the value retrieved from GCP<br>Secret Manager (or other implementor - see `secret_implementor`) using this key.<br><br>NOTE: if the secret does not exist, is misidentified, or if the VM cannot read<br>the secret value associated with this key, then the BIG-IP onboarding will fail<br>to complete, and onboarding will require manual intervention. | `string` | n/a | yes |
| as3\_payloads | An optional, but recommended, list of AS3 JSON declarations that can be used to<br>setup the BIG-IP instances. If left empty (default), a no-op AS3 declaration<br>will be generated for each instance.<br><br>The l | `list(string)` | `[]` | no |
| custom\_script | An optional, custom shell script that will be executed during BIG-IP<br>initialisation, after BIG-IP networking is auto-configured, admin password is set from Secret<br>Manager (if possible), etc. Declarative Onboarding offers a better approach,<br>where suitable (see `do_payload`).<br><br>NOTE: this value should contain the script contents, not a file path. | `string` | `""` | no |
| default\_gateway | Set this to the value to use as the default gateway for BIG-IP instances. This<br>could be an IP address, a shell command, or environment variable to use at<br>run-time. Set to blank to delete the default gateway without an explicit<br>replacement.<br><br>Default value is '$EXT\_GATEWAY' which will match the run-time upstream gateway<br>for nic0.<br><br>NOTE: this string will be inserted into the boot script as-is. | `string` | `"$EXT_GATEWAY"` | no |
| do\_filter\_jq | An optional JQ filter to apply to DO payloads prior to apply. Default is an empty<br>string. | `string` | `""` | no |
| do\_payloads | A list of Declarative Onboarding JSON that will be used to setup the BIG-IP<br>instance. | `list(string)` | n/a | yes |
| enable\_os\_login | Set to true to enable OS Login on the VMs. Default value is false. If disabled<br>you must ensure that SSH keys are set explicitly for this instance (see<br>`ssh_keys` or set in project metadata. | `bool` | `false` | no |
| enable\_serial\_console | Set to true to enable serial port console on the VMs. Default value is false. | `bool` | `false` | no |
| extramb | The amount of extra RAM (in Mb) to allocate to BIG-IP administrative processes.<br>The default of 1000 is a recommended minimum for BIG-IP instances on GCP; setting<br>too low can cause issues when applying large DO or AS3 payloads. | `number` | `1000` | no |
| image | The self-link URI for a BIG-IP image to use as a base for the VM cluster. This<br>can be an official F5 image from GCP Marketplace, or a customised image. | `string` | n/a | yes |
| install\_cloud\_libs | An optional list of cloud library URLs that will be downloaded and installed on<br>the BIG-IP VM during initial boot. The contents of each download will be compared<br>to the verifyHash file, and failure will cause the boot scripts to fail. Default<br>list will install F5 Cloud Libraries (w/GCE extension), AS3, Declarative<br>Onboarding, and Telemetry Streaming extensions. | `list(string)` | <pre>[<br>  "https://cdn.f5.com/product/cloudsolutions/f5-cloud-libs/v4.23.1/f5-cloud-libs.tar.gz",<br>  "https://cdn.f5.com/product/cloudsolutions/f5-cloud-libs-gce/v2.7.0/f5-cloud-libs-gce.tar.gz",<br>  "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.24.0/f5-appsvcs-3.24.0-5.noarch.rpm",<br>  "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.17.0/f5-declarative-onboarding-1.17.0-3.noarch.rpm",<br>  "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.16.0/f5-telemetry-1.16.0-4.noarch.rpm"<br>]</pre> | no |
| metadata | An optional map of initial metadata values that will be the base of generated<br>metadata. | `map(string)` | `{}` | no |
| num\_instances | The number of BIG-IP metadata sets to provision. Default value is 1. | `number` | `1` | no |
| region | An optional region attribute to include in usage analytics. Default value is an<br>empty string. | `string` | `""` | no |
| secret\_implementor | The secret retrieval implementor to use; default value is an empty string.<br>Must be an empty string, 'google\_secret\_manager', or 'metadata'. Future<br>enhancements will add other implementors. | `string` | `""` | no |
| ssh\_keys | An optional set of SSH public keys, concatenated into a single string. The keys<br>will be added to instance metadata. Default is an empty string.<br><br>See also `enable_os_login`. | `string` | `""` | no |
| use\_cloud\_init | If this value is set to true, cloud-init will be used as the initial<br>configuration approach; false (default) will fall-back to a standard shell<br>script for boot-time configuration.<br><br>Note: the BIG-IP version must support Cloud Init on GCP for this to function<br>correctly. E.g. v15.1+. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| metadata | The list of metadata maps to apply to instances. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
