# BIG-IP HA cluster module

> You are viewing a **2.x release** of the modules, which supports
> **Terraform 0.13 and 0.14** only. *For modules compatible with Terraform 0.12,
> use a 1.x release.* Functionality is identical, but separate releases are
> required due to the difference in *variable validation* between Terraform 0.12
> and 0.13+.

This module encapsulates the creation of BIG-IP HA cluster with ConfigSync
enabled.

> **NOTE:** This module is unsupported and not an official F5 product. If you
> require assistance please join our
> [Slack GCP channel](https://f5cloudsolutions.slack.com/messages/gcp) and ask!

## Example

This will create a pair of BIG-IP instances with ConfigSync enabled.

> **NOTE:** As with other BIG-IP modules in this repo, the Admin user password
> must be stored in Secret Manager with read-only access granted to the service
> account.

<!-- spell-checker: disable -->
```hcl
module "ha" {
  source                            = "memes/f5-bigip/google//modules/ha"
  version                           = "2.0.2"
  project_id                        = "my-project-id"
  num_instances                     = 2
  zones                             = ["us-central1-a", "us-central1-b"]
  machine_type                      = "n1-standard-8"
  service_account                   = "bigip-sa@my-project-id.iam.gserviceaccount.com"
  external_subnetwork               = "projects/my-project-id/regions/us-central1/subnetworks/external-central1"
  external_subnetwork_network_ips   = ["10.0.0.10", "10.0.0.11"]
  management_subnetwork             = "projects/my-project-id/regions/us-central1/subnetworks/management-central1"
  management_subnetwork_network_ips = ["10.0.1.10", "10.0.1.11"]
  internal_subnetworks              = ["projects/my-project-id/regions/us-central1/subnetworks/internal-central1"]
  internal_subnetwork_network_ips   = ["10.0.2.10", "10.0.2.11"]
  image                             = "projects/f5-7626-networks-public/global/images/f5-bigip-15-1-2-0-0-9-payg-good-5gbps-201110225418"
  allow_phone_home                  = false
  allow_usage_analytics             = false
  admin_password_secret_manager_key = "bigip-admin-key"
}
```
<!-- spell-checker: enable -->

<!-- spell-checker:ignore markdownlint bigip oslogin subnetwork subnetworks NICs byol payg Skylake preemptible VCPUS routable zoneinfo -->
<!-- markdownlint-disable MD033 MD034 -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | > 0.12 |
| google | >= 3.48 |

## Providers

No provider.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_password\_secret\_manager\_key | The Secret Manager key for BIG-IP admin password; during initialisation, the<br>BIG-IP admin account's password will be changed to the value retrieved from GCP<br>Secret Manager (or other implementor - see `secret_implementor`) using this key.<br><br>NOTE: if the secret does not exist, is misidentified, or if the VM cannot read<br>the secret value associated with this key, then the BIG-IP onboarding will fail<br>to complete, and onboarding will require manual intervention. | `string` | n/a | yes |
| allow\_phone\_home | Allow the BIG-IP VMs to send high-level device use information to help F5<br>optimize development resources. If set to false the information is not sent. | `bool` | `true` | no |
| allow\_usage\_analytics | Allow the BIG-IP VMs to send anonymous statistics to F5 to help us determine how<br>to improve our solutions (default). If set to false no statistics will be sent. | `bool` | `true` | no |
| as3\_payloads | An optional, but recommended, list of AS3 JSON files that can be used to setup<br>the BIG-IP instances. If left empty (default), the module will use a simple<br>no-op AS3 declaration. | `list(string)` | `[]` | no |
| automatic\_restart | Determines if the BIG-IP VMs should be automatically restarted if terminated by<br>GCE. Defaults to true to match expected GCE behaviour. | `bool` | `true` | no |
| custom\_script | An optional, custom shell script that will be executed during BIG-IP<br>initialisation, after BIG-IP networking is auto-configured, admin password is set from Secret<br>Manager (if possible), etc. Declarative Onboarding offers a better approach,<br>where suitable (see `do_payload`).<br><br>NOTE: this value should contain the script contents, not a file path. | `string` | `""` | no |
| default\_gateway | Set this to the value to use as the default gateway for BIG-IP instances. This<br>could be an IP address or environment variable to use at run-time. If left blank,<br>the onboarding script will use the gateway for nic0.<br><br>Default value is '$EXT\_GATEWAY' which will match the run-time upstream gateway<br>for nic0.<br><br>NOTE: this string will be inserted into the boot script as-is; it can be an IPv4<br>address, or a shell variable that is known to exist during network configuration<br>script execution. | `string` | `"$EXT_GATEWAY"` | no |
| delete\_disk\_on\_destroy | Set this flag to false if you want the boot disk associated with the launched VMs<br>to survive when instances are destroyed. The default value of true will ensure the<br>boot disk is destroyed when the instance is destroyed. | `bool` | `true` | no |
| disk\_size\_gb | Use this flag to set the boot volume size in GB. If left at the default value<br>the boot disk will have the same size as specified in 'bigip\_image'. | `number` | `null` | no |
| disk\_type | The boot disk type to use with instances; can be 'pd-ssd' (default), or<br>'pd-standard'.<br>\*Note:\* Choosing 'pd-standard' will reduce operating cost, but at the expense of<br>network performance. | `string` | `"pd-ssd"` | no |
| dns\_servers | An optional list of DNS servers for BIG-IP instances to use, if explicit DO files<br>are not provided. The default is ["169.254.169.254"] to use GCE metadata server. | `list(string)` | <pre>[<br>  "169.254.169.254"<br>]</pre> | no |
| do\_payloads | The Declarative Onboarding contents to apply to the instances. This<br>module has migrated to use of Declarative Onboarding for module activation,<br>licensing, NTP, DNS, and other<br>basic configurations. Sample payloads are in the examples folder.<br><br>Note: if left empty, the module will use a simple JSON that sets NTP and DNS,<br>and enables LTM module, and configures a sync-group with active-standby failover<br>among the instances. | `list(string)` | `[]` | no |
| domain\_name | An optional domain name to append to generated instance names to fully-qualify<br>them. If an empty string (default), then the instances will be qualified as-per<br>Google Cloud internal naming conventions ".ZONE.c.PROJECT\_ID.internal". | `string` | `""` | no |
| enable\_os\_login | Set to true to enable OS Login on the VMs. Default value is false as BIG-IP does<br>not support in OS Login mode currently.<br>NOTE: this value will override an 'enable-oslogin' key in `metadata` map. | `bool` | `false` | no |
| enable\_serial\_console | Set to true to enable serial port console on the VMs. Default value is false. | `bool` | `false` | no |
| external\_subnetwork | The fully-qualified self-link of the subnet that will be used for external ingress<br>(2+ NIC deployment), or for all traffic in a 1NIC deployment. | `string` | n/a | yes |
| external\_subnetwork\_network\_ips | An optional list of private IP addresses to assign to BIG-IP instances on their<br>external interface. | `list(string)` | `[]` | no |
| external\_subnetwork\_public\_ips | An optional list of public IP addresses to assign to BIG-IP instances on their<br>external interface. The list may be empty, or contain empty strings, to selectively<br>applies addresses to instances.<br><br>Note: these values are only applied if `provision_external_public_ip` is 'true'<br>and will be ignored if that value is false. | `list(string)` | `[]` | no |
| external\_subnetwork\_tier | The network tier to set for external subnetwork; must be one of 'PREMIUM'<br>(default) or 'STANDARD'. This setting only applies if the external interface is<br>permitted to have a public IP address (see `provision_external_public_ip`) | `string` | `"PREMIUM"` | no |
| external\_subnetwork\_vip\_cidrs | An optional list of VIP CIDRs to assign to the *active* BIG-IP instances on its<br>external interface. E.g. to assign two CIDR blocks as VIPs:-<br><br>external\_subnetwork\_vip\_cidrs = [<br>  "10.1.0.0/16",<br>  "10.2.0.0/24",<br>] | `list(string)` | `[]` | no |
| extramb | The amount of extra RAM (in Mb) to allocate to BIG-IP administrative processes.<br>The default of 1000 is a recommended minimum for BIG-IP instances on GCP; setting<br>too low can cause issues when applying large DO or AS3 payloads. | `number` | `1000` | no |
| image | The self-link URI for a BIG-IP image to use as a base for the VM cluster. This<br>can be an official F5 image from GCP Marketplace, or a customised image. | `string` | n/a | yes |
| install\_cloud\_libs | An optional list of cloud library URLs that will be downloaded and installed on<br>the BIG-IP VM during initial boot. The contents of each download will be compared<br>to the verifyHash file, and failure will cause the boot scripts to fail. Default<br>list will install F5 Cloud Libraries (w/GCE extension), AS3, Declarative<br>Onboarding, and Telemetry Streaming extensions. | `list(string)` | <pre>[<br>  "https://cdn.f5.com/product/cloudsolutions/f5-cloud-libs/v4.23.1/f5-cloud-libs.tar.gz",<br>  "https://cdn.f5.com/product/cloudsolutions/f5-cloud-libs-gce/v2.7.0/f5-cloud-libs-gce.tar.gz",<br>  "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.24.0/f5-appsvcs-3.24.0-5.noarch.rpm",<br>  "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.17.0/f5-declarative-onboarding-1.17.0-3.noarch.rpm",<br>  "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.16.0/f5-telemetry-1.16.0-4.noarch.rpm"<br>]</pre> | no |
| instance\_name\_template | A format string that will be used when naming instance, that should include a<br>format token for including integer ordinal numbers as defined in Go `fmt` package,<br>including support for zero-padding etc. Default value is 'bigip-%d' which will<br>generate names of 'bigip-0', 'bigip-1', through 'bigip-N', where N is the number<br>of instances - 1.<br><br>Examples:<br>instance\_name\_template = "bigip-%03d" will create instances named 'bigip-000',<br>'bigip-001', etc.<br>instance\_name\_template = "prod-ha-%x" will create instances using lower-case hex<br>, such as 'prod-ha-0' ... 'prod-ha-1f'.<br><br>See `instance_ordinal_offset` variable to change the lower bounds of the numbering<br>scheme. | `string` | `"bigip-%d"` | no |
| instance\_ordinal\_offset | An offset to apply to each instance ordinal when naming; use to change zero-based<br>instance ordinal to a different number when setting instance names and hostnames.<br>Default value is '0'.<br><br>E.g. to change 0-based instance names ('bigip-0', 'bigip-1', etc.) to 1-based<br>instance names ('bigip-1', 'bigip-2', etc.) use<br>instance\_ordinal\_offset = 1<br><br>See `instance_name_template` for more examples. | `number` | `0` | no |
| internal\_subnetwork\_network\_ips | A list of lists of private IP addresses to assign to BIG-IP instances on their<br>internal interfaces. Required if the instances have 3+ networks defined.<br><br>E.g. to assign addresses to two internal networks:-<br><br>internal\_subnetwork\_network\_ips = [<br>  # Will be assigned to first instance<br>  [<br>    "10.0.0.4", # first internal nic<br>    "10.0.1.4", # second internal nic<br>  ],<br>  # Will be assigned to second instance<br>  [<br>    "10.0.0.5",<br>    "10.0.1.5",<br>  ],<br>  ...<br>] | `list(list(string))` | `[]` | no |
| internal\_subnetwork\_public\_ips | An optional list of lists of public IP addresses to assign to BIG-IP instances<br>on their internal interface. The list may be empty, or contain empty strings, to<br>selectively applies addresses to instances.<br><br>Note: these values are only applied if `provision_internal_public_ip` is 'true'<br>and will be ignored if that value is false.<br><br>E.g. to assign addresses to two internal networks:<br><br>internal\_subnetwork\_network\_ips = [<br>  # Will be assigned to first instance<br>  [<br>    "x.x.x.x", # first internal nic<br>    "y.y.y.y", # second internal nic<br>  ],<br>  # Will be assigned to second instance<br>  [<br>    ...<br>  ],<br>  ...<br>] | `list(list(string))` | `[]` | no |
| internal\_subnetwork\_tier | The network tier to set for internal subnetwork; must be one of 'PREMIUM'<br>(default) or 'STANDARD'. This setting only applies if the internal interface is<br>permitted to have a public IP address (see `provision_internal_public_ip`) | `string` | `"PREMIUM"` | no |
| internal\_subnetwork\_vip\_cidrs | An optional list of list of CIDRs to assign to *active* BIG-IP instance as VIPs<br>on its internal interface. E.g. to assign two CIDR blocks as VIPs:-<br><br>internal\_subnetwork\_vip\_cidrs = [<br>  ["10.1.0.0/16"], # assigned to first internal nic<br>  ["10.2.0.0/24"], # assigned to second internal nic<br>] | `list(list(string))` | `[]` | no |
| internal\_subnetworks | An optional list of fully-qualified subnet self-links that will be assigned as<br>internal traffic on NICs eth[2-8]. | `list(string)` | `[]` | no |
| labels | An optional map of *labels* to add to the instance template. | `map(string)` | `{}` | no |
| license\_type | A BIG-IP license type to use with the BIG-IP instance. Must be one of "byol" or<br>"payg", with "byol" as the default. If set to "payg", the image must be a PAYG<br>image from F5's official project or the instance will fail to onboard correctly. | `string` | `"byol"` | no |
| machine\_type | The machine type to use for BIG-IP VMs; this may be a standard GCE machine type,<br>or a customised VM ('custom-VCPUS-MEM\_IN\_MB'). Default value is 'n1-standard-4'.<br>\*Note:\* machine\_type is highly-correlated with network bandwidth and performance;<br>an N2 or N2D machine type will give better performance but has limited availability. | `string` | `"n1-standard-4"` | no |
| management\_subnetwork | An optional fully-qualified self-link of the subnet that will be used for<br>management access (2+ NIC deployment). | `string` | `null` | no |
| management\_subnetwork\_network\_ips | A list of private IP addresses to assign to BIG-IP instances on their management<br>interface. Required if there are 2+ NICs defined for instances. | `list(string)` | `[]` | no |
| management\_subnetwork\_public\_ips | An optional list of public IP addresses to assign to BIG-IP instances on their<br>management interface. The list may be empty, or contain empty strings, to<br>selectively applies addresses to instances.<br><br>Note: these values are only applied if `provision_management_public_ip` is 'true'<br>and will be ignored if that value is false. | `list(string)` | `[]` | no |
| management\_subnetwork\_tier | The network tier to set for management subnetwork; must be one of 'PREMIUM'<br>(default) or 'STANDARD'. This setting only applies if the management interface is<br>permitted to have a public IP address (see `provision_management_public_ip`) | `string` | `"PREMIUM"` | no |
| management\_subnetwork\_vip\_cidrs | An optional list of CIDRs to assign to *active* BIG-IP instance as VIPs on its<br>management interface. E.g. to assign two CIDR blocks as VIPs:-<br><br>management\_subnetwork\_vip\_cidrs = [<br>  "10.1.0.0/16",<br>  "10.2.0.0/24",<br>] | `list(string)` | `[]` | no |
| metadata | An optional map of metadata values that will be applied to the instances. | `map(string)` | `{}` | no |
| min\_cpu\_platform | An optional constraint used when scheduling the BIG-IP VMs; this value prevents<br>the VMs from being scheduled on hardware that doesn't meet the minimum CPU<br>micro-architecture. Default value is 'Intel Skylake'. | `string` | `"Intel Skylake"` | no |
| modules | A map of BIG-IP module = provisioning-level pairs to enable, where the module<br>name is key, and the provisioning-level is the value. This value is used with the<br>default Declaration Onboarding template; a better option for full control is to<br>explicitly declare the modules to be provisioned as part of a custom JSON file.<br>See `do_payload`.<br><br>E.g. the default is<br>modules = {<br>  ltm = "nominal"<br>}<br><br>To provision ASM and LTM, the value might be:-<br>modules = {<br>  ltm = "nominal"<br>  asm = "nominal"<br>} | `map(string)` | <pre>{<br>  "ltm": "nominal"<br>}</pre> | no |
| ntp\_servers | An optional list of NTP servers for BIG-IP instances to use. The default is<br>["169.254.169.254"] to use GCE metadata server. | `list(string)` | <pre>[<br>  "169.254.169.254"<br>]</pre> | no |
| num\_instances | The number of BIG-IP instances to provision in HA cluster. Default value is 2. | `number` | `2` | no |
| preemptible | If set to true, the BIG-IP instances will be deployed on preemptible VMs, which<br>could be terminated at any time, and have a maximum lifetime of 24 hours. Default<br>value is false. | `string` | `false` | no |
| project\_id | The GCP project identifier where the cluster will be created. | `string` | n/a | yes |
| provision\_external\_public\_ip | If this flag is set to true (default), a publicly routable IP address WILL be<br>assigned to the external interface of instances. If set to false, the BIG-IP<br>instances will NOT have a public IP address assigned to the external interface. | `bool` | `true` | no |
| provision\_internal\_public\_ip | If this flag is set to true, a publicly routable IP address WILL be assigned to<br>the internal interfaces of instances. If set to false (default), the BIG-IP<br>instances will NOT have a public IP address assigned to the internal interfaces. | `bool` | `false` | no |
| provision\_management\_public\_ip | If this flag is set to true, a publicly routable IP address WILL be assigned to<br>the management interface of instances. If set to false (default), the BIG-IP<br>instances will NOT have a public IP address assigned to the management interface. | `bool` | `false` | no |
| search\_domains | An optional list of DNS search domains for BIG-IP instances to use, if explicit<br>DO files are not provided. If left empty (default), search domains will be added<br>for "google.internal" and the zone/project specific domain assigned to instances. | `list(string)` | `[]` | no |
| secret\_implementor | The secret retrieval implementor to use; default value is an empty string.<br>Must be an empty string, 'google\_secret\_manager', or 'metadata'. Future<br>enhancements will add other implementors. | `string` | `""` | no |
| service\_account | The service account that will be used for the BIG-IP VMs. | `string` | n/a | yes |
| ssh\_keys | An optional set of SSH public keys, concatenated into a single string. The keys<br>will be added to instance metadata. Default is an empty string.<br><br>See also `enable_os_login`. | `string` | `""` | no |
| tags | An optional list of *network tags* to add to the instance template. | `list(string)` | `[]` | no |
| timezone | The Olson timezone string from /usr/share/zoneinfo for BIG-IP instances. The<br>default is 'UTC'. See the TZ column here<br>(https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for legal values.<br>For example, 'US/Eastern'. | `string` | `"UTC"` | no |
| use\_cloud\_init | If this value is set to true, cloud-init will be used as the initial<br>configuration approach; false (default) will fall-back to a standard shell<br>script for boot-time configuration.<br><br>Note: the BIG-IP version must support Cloud Init on GCP for this to function<br>correctly. E.g. v15.1+. | `bool` | `false` | no |
| zones | The compute zones which will host the BIG-IP VMs. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| external\_addresses | A list of the IP addresses and alias CIDRs assigned to instances on the external<br>NIC. |
| external\_public\_ips | A list of the public IP addresses assigned to instances on the external NIC. |
| external\_vips | A list of IP CIDRs assigned to the active instance on its external NIC. |
| instance\_addresses | A map of instance name to assigned IP addresses and alias CIDRs. |
| internal\_addresses | A list of the IP addresses and alias CIDRs assigned to instances on the internal<br>NICs, if present. |
| internal\_public\_ips | A list of the public IP addresses assigned to instances on the internal NICs,<br>if present. |
| management\_addresses | A list of the IP addresses and alias CIDRs assigned to instances on the<br>management NIC, if present. |
| management\_public\_ips | A list of the public IP addresses assigned to instances on the management NIC,<br>if present. |
| self\_links | A list of self-links of the BIG-IP instances. |
| zone\_instances | A map of compute zones from var.zones input variable to instance self-links. If<br>no instances are deployed to a zone, the mapping will be to an empty list.<br><br>E.g. if `var.zones = ["us-east1-a", "us-east1-b", "us-east1-c"]` and<br>`var.num_instances = 2` then the output will be:<br>{<br>  us-east1-a = [self-link-instance0]<br>  us-east1-b = [self-link-instance1]<br>  us-east1-c = []<br>} |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
