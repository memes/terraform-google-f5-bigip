# BIG-IP metadata module

This module encapsulates the creation of a BIG-IP image template for consumption
by other Terraform modules.

*Note:* This module is unsupported and not an official F5 product.

## Configuration

<!-- spell-checker:ignore markdownlint hostnames byol payg zoneinfo -->
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
| admin\_password\_secret\_manager\_key | The Secret Manager key for BIG-IP admin password; during initialisation, the<br>BIG-IP admin account's password will be changed to the value retrieved from GCP<br>Secret Manager using this key.<br><br>NOTE: if the secret does not exist, is misidentified, or if the VM cannot read<br>the secret value associated with this key, then the BIG-IP onboarding will fail<br>to complete, and onboarding will require manual intervention. | `string` | n/a | yes |
| allow\_phone\_home | Allow the BIG-IP VMs to send high-level device use information to help F5<br>optimize development resources. If set to false the information is not sent. | `bool` | `true` | no |
| allow\_usage\_analytics | Allow the BIG-IP VMs to send anonymous statistics to F5 to help us determine how<br>to improve our solutions (default). If set to false no statistics will be sent. | `bool` | `true` | no |
| as3\_payloads | An optional, but recommended, list of AS3 JSON declarations that can be used to<br>setup the BIG-IP instances. If left empty (default), a no-op AS3 declaration<br>will be generated for each instance.<br><br>The l | `list(string)` | `[]` | no |
| custom\_script | An optional, custom shell script that will be executed during BIG-IP<br>initialisation, after BIG-IP networking is auto-configured, admin password is set from Secret<br>Manager (if possible), etc. Declarative Onboarding offers a better approach,<br>where suitable (see `do_payload`).<br><br>NOTE: this value should contain the script contents, not a file path. | `string` | `""` | no |
| default\_gateway | Set this to the value to use as the default gateway for BIG-IP instances. This<br>could be an IP address, a shell command, or environment variable to use at<br>run-time. Set to blank to delete the default gateway without an explicit<br>replacement.<br><br>Default value is '$EXT\_GATEWAY' which will match the run-time upstream gateway<br>for nic0.<br><br>NOTE: this string will be inserted into the boot script as-is. | `string` | `"$EXT_GATEWAY"` | no |
| dns\_servers | An optional list of DNS servers for BIG-IP instances to use. The default is<br>["169.254.169.254"] to use GCE metadata server. | `list(string)` | <pre>[<br>  "169.254.169.254"<br>]</pre> | no |
| do\_payloads | An optional, but recommended, list of Declarative Onboarding JSON that can be used to<br>setup the BIG-IP instance. If left blank (default), a minimal Declarative<br>Onboarding will be generated and used. | `list(string)` | `[]` | no |
| enable\_os\_login | Set to true to enable OS Login on the VMs. Default value is false. If disabled<br>you must ensure that SSH keys are set explicitly for this instance (see<br>`ssh_keys` or set in project metadata. | `bool` | `false` | no |
| enable\_serial\_console | Set to true to enable serial port console on the VMs. Default value is false. | `bool` | `false` | no |
| hostnames | An optional list of hostname declarations to set per-instance hostname in<br>generated DO file. Default is an empty list, which will exclude hostname<br>from the generated DO file. | `list(string)` | `[]` | no |
| image | The self-link URI for a BIG-IP image to use as a base for the VM cluster. This<br>can be an official F5 image from GCP Marketplace, or a customised image. | `string` | n/a | yes |
| install\_cloud\_libs | An optional list of cloud library URLs that will be downloaded and installed on<br>the BIG-IP VM during initial boot. The contents of each download will be compared<br>to the verifyHash file, and failure will cause the boot scripts to fail. Default<br>list will install F5 Cloud Libraries (w/GCE extension), AS3, and Declarative<br>Onboarding extensions. | `list(string)` | <pre>[<br>  "https://cdn.f5.com/product/cloudsolutions/f5-cloud-libs/v4.22.0/f5-cloud-libs.tar.gz",<br>  "https://cdn.f5.com/product/cloudsolutions/f5-cloud-libs-gce/v2.6.0/f5-cloud-libs-gce.tar.gz",<br>  "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.22.1/f5-appsvcs-3.22.1-1.noarch.rpm",<br>  "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.15.0/f5-declarative-onboarding-1.15.0-3.noarch.rpm"<br>]</pre> | no |
| license\_type | A BIG-IP license type to use with the BIG-IP instance. Must be one of "byol" or<br>"payg", with "byol" as the default. If set to "payg", the image must be a PAYG<br>image from F5's official project or the instance will fail to onboard correctly. | `string` | `"byol"` | no |
| metadata | An optional map of initial metadata values that will be the base of generated<br>metadata. | `map(string)` | `{}` | no |
| modules | A map of BIG-IP module = provisioning-level pairs to enable, where the module<br>name is key, and the provisioning-level is the value. This value is used with the<br>default Declaration Onboarding template; a better option for full control is to<br>explicitly declare the modules to be provisioned as part of a custom JSON file.<br>See `do_payload`.<br><br>E.g. the default is<br>modules = {<br>  ltm = "nominal"<br>}<br><br>To provision ASM and LTM, the value might be:-<br>modules = {<br>  ltm = "nominal"<br>  asm = "nominal"<br>} | `map(string)` | <pre>{<br>  "ltm": "nominal"<br>}</pre> | no |
| ntp\_servers | An optional list of NTP servers for BIG-IP instances to use. The default is<br>["169.254.169.254"] to use GCE metadata server. | `list(string)` | <pre>[<br>  "169.254.169.254"<br>]</pre> | no |
| num\_instances | The number of BIG-IP metadata sets to provision. Default value is 1. | `number` | `1` | no |
| region | An optional region attribute to include in usage analytics. Default value is an<br>empty string. | `string` | `""` | no |
| search\_domains | An optional list of DNS search domains for BIG-IP instances to use. The default<br>is ["google.internal"]. | `list(string)` | <pre>[<br>  "google.internal"<br>]</pre> | no |
| ssh\_keys | An optional set of SSH public keys, concatenated into a single string. The keys<br>will be added to instance metadata. Default is an empty string.<br><br>See also `enable_os_login`. | `string` | `""` | no |
| timezone | The Olson timezone string from /usr/share/zoneinfo for BIG-IP instances. The<br>default is 'UTC'. See the TZ column here<br>(https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for legal values.<br>For example, 'US/Eastern'. | `string` | `"UTC"` | no |
| use\_cloud\_init | If this value is set to true, cloud-init will be used as the initial<br>configuration approach; false (default) will fall-back to a standard shell<br>script for boot-time configuration.<br><br>Note: the BIG-IP version must support Cloud Init on GCP for this to function<br>correctly. E.g. v15.1+. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| metadata | The list of metadata maps to apply to instances. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
