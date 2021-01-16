# CFE

This folder contains a fixture for testing all the options available in the cfe,
cfe-role, and configsync-fw modules. Where an input is optional in the cfe module,
a default value will be provided in `variables.tf` but can be overridden by
scenarios as set in kitchen.yml.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | > 0.12 |
| google | ~> 3.48 |
| google | ~> 3.48 |
| google-beta | ~> 3.48 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.48 ~> 3.48 |
| google.executor | ~> 3.48 ~> 3.48 |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_password\_secret\_manager\_key | The Secret Manager key for BIG-IP admin password. | `string` | n/a | yes |
| alpha\_net | Self-link of alpha network. | `string` | n/a | yes |
| alpha\_subnet | Self-link of alpha subnet. | `string` | n/a | yes |
| beta\_net | Self-link of beta network. | `string` | n/a | yes |
| beta\_subnet | Self-link of beta subnet. | `string` | n/a | yes |
| cfe\_label\_value | The CFE label value to assign to resources that are going to be managed by this<br>BIG-IP deployment. This value must uniquely identify a resource set and is a<br>required configuration value. | `string` | n/a | yes |
| delta\_net | Self-link of delta network. | `string` | n/a | yes |
| delta\_subnet | Self-link of delta subnet. | `string` | n/a | yes |
| epsilon\_net | Self-link of epsilon network. | `string` | n/a | yes |
| epsilon\_subnet | Self-link of epsilon subnet. | `string` | n/a | yes |
| eta\_net | Self-link of eta network. | `string` | n/a | yes |
| eta\_subnet | Self-link of eta subnet. | `string` | n/a | yes |
| gamma\_net | Self-link of gamma network. | `string` | n/a | yes |
| gamma\_subnet | Self-link of gamma subnet. | `string` | n/a | yes |
| num\_nics | The number of network interfaces to provision in BIG-IP test instances. | `number` | n/a | yes |
| prefix | The prefix to apply to GCP resources created in this test run. | `string` | n/a | yes |
| project\_id | The GCP project identifier where the cluster will be created. | `string` | n/a | yes |
| region | The compute region which will host the BIG-IP VMs. | `string` | n/a | yes |
| reserve\_addresses | Toggle the use of address reservation in scenario; if true then a set of addresses<br>will be reserved on networks and supplied to BIG-IP module. This will include<br>public reservations if `provision_[TYPE]_public_ip` is set to true. | `bool` | n/a | yes |
| service\_account | The service account to use with BIG-IP. | `string` | n/a | yes |
| theta\_net | Self-link of theta network. | `string` | n/a | yes |
| theta\_subnet | Self-link of theta subnet. | `string` | n/a | yes |
| zeta\_net | Self-link of zeta network. | `string` | n/a | yes |
| zeta\_subnet | Self-link of zeta subnet. | `string` | n/a | yes |
| allow\_phone\_home | Allow the BIG-IP VMs to send high-level device use information to help F5<br>optimize development resources. If set to false the information is not sent. | `bool` | `true` | no |
| as3\_payloads | An optional, but recommended, list of AS3 JSON files that can be used to setup<br>the BIG-IP instances. If left empty (default), the module will use a simple<br>no-op AS3 declaration. | `list(string)` | `[]` | no |
| automatic\_restart | Determines if the BIG-IP VMs should be automatically restarted if terminated by<br>GCE. | `bool` | `true` | no |
| cfe\_label\_key | The CFE label key to assign to resources that are going to be managed by CFE.<br>Default value is 'f5\_cloud\_failover\_label'. | `string` | `"f5_cloud_failover_label"` | no |
| cfe\_payload | The CFE payload contents to apply to the instances; default is an empty string.<br><br>Note: if left empty, the module will use a simple JSON that sets the CFE scoping<br>label pair on storage, and failover addresses, but nothing more. You will need to<br>override and provide the correct CFE payload for your environment. | `string` | `""` | no |
| default\_gateway | Set this to the value to use as the default gateway for BIG-IP instances. This<br>must be a valid IP address or an empty string. If left blank (default), the<br>generated Declarative Onboarding JSON will use the gateway associated with nic0<br>at run-time. | `string` | `""` | no |
| delete\_disk\_on\_destroy | Set this flag to false if you want the boot disk associated with the launched VMs<br>to survive when instances are destroyed. | `bool` | `true` | no |
| disk\_size\_gb | Use this flag to set the boot volume size in GB. | `number` | `null` | no |
| disk\_type | The boot disk type to use with instances; can be 'pd-ssd' (default), or<br>'pd-standard'. | `string` | `"pd-ssd"` | no |
| dns\_servers | An optional list of DNS servers for BIG-IP instances to use if custom DO payloads<br>are not provided. The default is ["169.254.169.254"] to use GCE metadata server. | `list(string)` | <pre>[<br>  "169.254.169.254"<br>]</pre> | no |
| do\_payloads | The Declarative Onboarding contents to apply to the instances. Required. This<br>module has migrated to use of Declarative Onboarding for module activation,<br>licensing, NTP, DNS, and other basic configurations. Sample payloads are in the<br>examples folder.<br><br>Note: if left empty, the module will use a simple JSON that sets NTP and DNS,<br>and enables LTM. | `list(string)` | `[]` | no |
| domain\_name | An optional domain name to append to generated instance names to fully-qualify<br>them. | `string` | `""` | no |
| enable\_serial\_console | Set to true to enable serial port console on the VMs. Default value is false. | `bool` | `false` | no |
| external\_subnetwork\_tier | The network tier to set for external subnetwork; must be one of 'PREMIUM'<br>(default) or 'STANDARD'. | `string` | `"PREMIUM"` | no |
| extramb | The amount of extra RAM (in Mb) to allocate to BIG-IP administrative processes;<br>must be an integer between 0 and 2560. The default of 2048 is recommended for<br>BIG-IP instances on GCP; setting too low can cause issues when applying DO or<br>AS3 payloads. | `number` | `2048` | no |
| image | The self-link URI for a BIG-IP image to use as a base for the VM cluster. | `string` | `"projects/f5-7626-networks-public/global/images/f5-bigip-15-1-2-0-0-9-payg-good-25mbps-201110225418"` | no |
| install\_cloud\_libs | An optional list of cloud library URLs that will be downloaded and installed on<br>the BIG-IP VM during initial boot. The contents of each download will be compared<br>to the verifyHash file, and failure will cause the boot scripts to fail. Default<br>list will install F5 Cloud Libraries (w/GCE extension), AS3, Declarative<br>Onboarding, CFE, and Telemetry Streaming extensions. | `list(string)` | <pre>[<br>  "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.24.0/f5-appsvcs-3.24.0-5.noarch.rpm",<br>  "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.17.0/f5-declarative-onboarding-1.17.0-3.noarch.rpm",<br>  "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.16.0/f5-telemetry-1.16.0-4.noarch.rpm",<br>  "https://github.com/F5Networks/f5-cloud-failover-extension/releases/download/v1.6.1/f5-cloud-failover-1.6.1-1.noarch.rpm"<br>]</pre> | no |
| instance\_name\_template | A format string that will be used when naming instances. | `string` | `"bigip-%d"` | no |
| instance\_ordinal\_offset | An offset to apply to each instance ordinal when naming. | `number` | `0` | no |
| internal\_subnetwork\_tier | The network tier to set for internal subnetwork; must be one of 'PREMIUM'<br>(default) or 'STANDARD'. | `string` | `"PREMIUM"` | no |
| labels | An optional map of *labels* to add to the instance template. | `map(string)` | `{}` | no |
| machine\_type | The machine type to use for BIG-IP VMs; this may be a standard GCE machine type,<br>or a customised VM ('custom-VCPUS-MEM\_IN\_MB'). | `string` | `"n1-standard-4"` | no |
| management\_subnetwork\_tier | The network tier to set for management subnetwork; must be one of 'PREMIUM'<br>(default) or 'STANDARD'. | `string` | `"PREMIUM"` | no |
| metadata | An optional map of metadata values that will be applied to the instances. | `map(string)` | `{}` | no |
| min\_cpu\_platform | An optional constraint used when scheduling the BIG-IP VMs; this value prevents<br>the VMs from being scheduled on hardware that doesn't meet the minimum CPU<br>micro-architecture. | `string` | `"Intel Skylake"` | no |
| modules | A map of BIG-IP module = provisioning-level pairs to enable, where the module<br>name is key, and the provisioning-level is the value. This value is used with the<br>default Declaration Onboarding template; a better option for full control is to<br>explicitly declare the modules to be provisioned as part of a custom JSON file.<br>See `do_payloads`.<br><br>E.g. the default is<br>modules = {<br>  ltm = "nominal"<br>}<br><br>To provision ASM and LTM, the value might be:-<br>modules = {<br>  ltm = "nominal"<br>  asm = "nominal"<br>} | `map(string)` | <pre>{<br>  "ltm": "nominal"<br>}</pre> | no |
| ntp\_servers | An optional list of NTP servers for BIG-IP instances to use if custom DO files<br>are not provided. The default is ["169.254.169.254"] to use GCE metadata server. | `list(string)` | <pre>[<br>  "169.254.169.254"<br>]</pre> | no |
| num\_instances | The number of BIG-IP instances to provision. | `number` | `2` | no |
| override\_admin\_password\_secret\_manager\_key | Override the Secret Manager key for BIG-IP admin password. | `string` | `""` | no |
| preemptible | If set to true, the BIG-IP instances will be deployed on preemptible VMs, which<br>could be terminated at any time, and have a maximum lifetime of 24 hours. | `string` | `false` | no |
| provision\_external\_public\_ip | If this flag is set to true (default), a publicly routable IP address WILL be<br>assigned to the external interface of instances. | `bool` | `true` | no |
| provision\_internal\_public\_ip | If this flag is set to true, a publicly routable IP address WILL be assigned to<br>the internal interfaces of instances. | `bool` | `false` | no |
| provision\_management\_public\_ip | If this flag is set to true, a publicly routable IP address WILL be assigned to<br>the management interface of instances. | `bool` | `false` | no |
| search\_domains | An optional list of DNS search domains for BIG-IP instances to use if custom DO<br>payloads are not provided. If left empty (default), search domains will be added<br>for "google.internal" and the zone/project specific domain assigned to instances. | `list(string)` | `[]` | no |
| secret\_implementor | The secret retrieval implementor to use; default value is an empty string.<br>Must be an empty string, 'google\_secret\_manager', or 'metadata'. Future<br>enhancements will add other implementors. | `string` | `""` | no |
| ssh\_keys | An optional set of SSH public keys, concatenated into a single string. | `string` | `""` | no |
| tags | An optional list of *network tags* to add to the instance template. | `list(string)` | `[]` | no |
| tf\_sa\_email | The fully-qualified email address of the Terraform service account to use for<br>resource creation via account impersonation. If left blank, the default, then<br>the invoker's account will be used.<br><br>E.g. if you have permissions to impersonate:<br><br>tf\_sa\_email = "terraform@PROJECT\_ID.iam.gserviceaccount.com" | `string` | `""` | no |
| tf\_sa\_token\_lifetime\_secs | The expiration duration for the service account token, in seconds. This value<br>should be high enough to prevent token timeout issues during resource creation,<br>but short enough that the token is useless replayed later. Default value is 600<br>(10 mins). | `number` | `600` | no |
| timezone | The Olson timezone string from /usr/share/zoneinfo for BIG-IP instances if custom<br>DO files are not provided. The default is 'UTC'. See the TZ column here<br>(https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for legal values.<br>For example, 'US/Eastern'. | `string` | `"UTC"` | no |
| use\_cloud\_init | If this value is set to true, cloud-init will be used as the initial<br>configuration approach. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| admin\_password\_secret\_manager\_key | The Secret Manager key for BIG-IP admin password. |
| alpha\_net | The self-link of alpha network. |
| alpha\_subnet | The self-link of alpha subnet. |
| beta\_net | The self-link of beta network. |
| beta\_subnet | The self-link of beta subnet. |
| cfe\_label\_key | The CFE label key to assign to resources that are going to be managed by CFE. |
| dataplane\_fw\_self\_link | The self-link for the ConfigSync firewall rule added to data-plane network. |
| delta\_net | The self-link of delta network. |
| delta\_subnet | The self-link of delta subnet. |
| epsilon\_net | The self-link of epsilon network. |
| epsilon\_subnet | The self-link of epsilon subnet. |
| eta\_net | The self-link of eta network. |
| eta\_subnet | The self-link of eta subnet. |
| external\_addresses | A list of the IP addresses and alias CIDRs assigned to instances on the external<br>NIC. |
| external\_public\_ips | A list of the public IP addresses assigned to instances on the external NIC. |
| external\_vips | A list of IP CIDRs assigned to instances on the external NIC, which usually<br>corresponds to the VIPs defined on each instance. |
| gamma\_net | The self-link of gamma network. |
| gamma\_subnet | The self-link of gamma subnet. |
| instance\_addresses | A map of instance name to assigned IP addresses and alias CIDRs. |
| internal\_addresses | A list of the IP addresses and alias CIDRs assigned to instances on the internal<br>NICs, if present. |
| internal\_public\_ips | A list of the public IP addresses assigned to instances on the internal NICs,<br>if present. |
| management\_addresses | A list of the IP addresses and alias CIDRs assigned to instances on the<br>management NIC, if present. |
| management\_fw\_self\_link | The self-link for the ConfigSync firewall rule added to management network. |
| management\_public\_ips | A list of the public IP addresses assigned to instances on the management NIC,<br>if present. |
| prefix | The prefix prepended to generated resource names for this test. |
| private\_addresses | A list of list of private IP addresses that should be applied to the BIG-IP<br>instances. |
| project\_id | The project identifier being used for testing. |
| public\_addresses | A list of list of public IP addresses that should be applied to the BIG-IP<br>instances. |
| region | The compute region that will be used for BIG-IP resources. |
| role\_id | The qualified role-id for the custom CFE role. |
| self\_links | A list of self-links of the BIG-IP instances. |
| service\_account | The service account to use with the BIG-IP instances. |
| theta\_net | The self-link of theta network. |
| theta\_subnet | The self-link of theta subnet. |
| zeta\_net | The self-link of zeta network. |
| zeta\_subnet | The self-link of zeta subnet. |
| zone\_instances | A map of compute zones from var.zones input variable to instance self-links. If<br>no instances are deployed to a zone, the mapping will be to an empty list. |
| zones | The compute zones that will be used for BIG-IP instances. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
