# root

This folder contains a fixture for testing all the options available in the root
module. Where an input is optional in the root, a default value will be provided
in `variables.tf` but can be overridden by scenarios as set in kitchen.yml.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 0.12.28, < 0.13 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 3.48 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 3.48 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 3.48 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 3.48 ~> 3.48 |
| <a name="provider_google.executor"></a> [google.executor](#provider\_google.executor) | ~> 3.48 ~> 3.48 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_root"></a> [root](#module\_root) | ../../../ |  |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.alpha_private](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.alpha_public](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.beta_private](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.beta_public](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.delta_private](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.delta_public](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.epsilon_private](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.epsilon_public](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.eta_private](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.eta_public](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.gamma_private](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.gamma_public](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.theta_private](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.theta_public](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.zeta_private](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.zeta_public](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [random_shuffle.zones](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/shuffle) | resource |
| [google_client_config.executor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |
| [google_service_account_access_token.sa_token](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account_access_token) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password_secret_manager_key"></a> [admin\_password\_secret\_manager\_key](#input\_admin\_password\_secret\_manager\_key) | The Secret Manager key for BIG-IP admin password. | `string` | n/a | yes |
| <a name="input_alpha_net"></a> [alpha\_net](#input\_alpha\_net) | Self-link of alpha network. | `string` | n/a | yes |
| <a name="input_alpha_subnet"></a> [alpha\_subnet](#input\_alpha\_subnet) | Self-link of alpha subnet. | `string` | n/a | yes |
| <a name="input_beta_net"></a> [beta\_net](#input\_beta\_net) | Self-link of beta network. | `string` | n/a | yes |
| <a name="input_beta_subnet"></a> [beta\_subnet](#input\_beta\_subnet) | Self-link of beta subnet. | `string` | n/a | yes |
| <a name="input_delta_net"></a> [delta\_net](#input\_delta\_net) | Self-link of delta network. | `string` | n/a | yes |
| <a name="input_delta_subnet"></a> [delta\_subnet](#input\_delta\_subnet) | Self-link of delta subnet. | `string` | n/a | yes |
| <a name="input_epsilon_net"></a> [epsilon\_net](#input\_epsilon\_net) | Self-link of epsilon network. | `string` | n/a | yes |
| <a name="input_epsilon_subnet"></a> [epsilon\_subnet](#input\_epsilon\_subnet) | Self-link of epsilon subnet. | `string` | n/a | yes |
| <a name="input_eta_net"></a> [eta\_net](#input\_eta\_net) | Self-link of eta network. | `string` | n/a | yes |
| <a name="input_eta_subnet"></a> [eta\_subnet](#input\_eta\_subnet) | Self-link of eta subnet. | `string` | n/a | yes |
| <a name="input_gamma_net"></a> [gamma\_net](#input\_gamma\_net) | Self-link of gamma network. | `string` | n/a | yes |
| <a name="input_gamma_subnet"></a> [gamma\_subnet](#input\_gamma\_subnet) | Self-link of gamma subnet. | `string` | n/a | yes |
| <a name="input_num_nics"></a> [num\_nics](#input\_num\_nics) | The number of network interfaces to provision in BIG-IP test instances. | `number` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix to apply to GCP resources created in this test run. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project identifier where the cluster will be created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The compute region which will host the BIG-IP VMs. | `string` | n/a | yes |
| <a name="input_reserve_addresses"></a> [reserve\_addresses](#input\_reserve\_addresses) | Toggle the use of address reservation in scenario; if true then a set of addresses<br>will be reserved on networks and supplied to BIG-IP module. This will include<br>public reservations if `provision_[TYPE]_public_ip` is set to true. | `bool` | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | The service account to use with BIG-IP. | `string` | n/a | yes |
| <a name="input_theta_net"></a> [theta\_net](#input\_theta\_net) | Self-link of theta network. | `string` | n/a | yes |
| <a name="input_theta_subnet"></a> [theta\_subnet](#input\_theta\_subnet) | Self-link of theta subnet. | `string` | n/a | yes |
| <a name="input_zeta_net"></a> [zeta\_net](#input\_zeta\_net) | Self-link of zeta network. | `string` | n/a | yes |
| <a name="input_zeta_subnet"></a> [zeta\_subnet](#input\_zeta\_subnet) | Self-link of zeta subnet. | `string` | n/a | yes |
| <a name="input_allow_phone_home"></a> [allow\_phone\_home](#input\_allow\_phone\_home) | Allow the BIG-IP VMs to send high-level device use information to help F5<br>optimize development resources. If set to false the information is not sent. | `bool` | `true` | no |
| <a name="input_as3_payloads"></a> [as3\_payloads](#input\_as3\_payloads) | An optional, but recommended, list of AS3 JSON files that can be used to setup<br>the BIG-IP instances. If left empty (default), the module will use a simple<br>no-op AS3 declaration. | `list(string)` | `[]` | no |
| <a name="input_automatic_restart"></a> [automatic\_restart](#input\_automatic\_restart) | Determines if the BIG-IP VMs should be automatically restarted if terminated by<br>GCE. | `bool` | `true` | no |
| <a name="input_custom_script"></a> [custom\_script](#input\_custom\_script) | An optional, custom shell script that will be executed during BIG-IP<br>initialisation, after BIG-IP networking is auto-configured, admin password is set from Secret<br>Manager (if possible), etc. Declarative Onboarding offers a better approach,<br>where suitable (see `do_payload`).<br><br>NOTE: this value should contain the script contents, not a file path. | `string` | `""` | no |
| <a name="input_default_gateway"></a> [default\_gateway](#input\_default\_gateway) | Set this to the value to use as the default gateway for BIG-IP instances. This<br>must be a valid IP address or an empty string. If left blank (default), the<br>generated Declarative Onboarding JSON will use the gateway associated with nic0<br>at run-time. | `string` | `""` | no |
| <a name="input_delete_disk_on_destroy"></a> [delete\_disk\_on\_destroy](#input\_delete\_disk\_on\_destroy) | Set this flag to false if you want the boot disk associated with the launched VMs<br>to survive when instances are destroyed. | `bool` | `true` | no |
| <a name="input_disk_size_gb"></a> [disk\_size\_gb](#input\_disk\_size\_gb) | Use this flag to set the boot volume size in GB. | `number` | `null` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | The boot disk type to use with instances; can be 'pd-ssd' (default), or<br>'pd-standard'. | `string` | `"pd-ssd"` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | An optional list of DNS servers for BIG-IP instances to use if custom DO payloads<br>are not provided. The default is ["169.254.169.254"] to use GCE metadata server. | `list(string)` | <pre>[<br>  "169.254.169.254"<br>]</pre> | no |
| <a name="input_do_payloads"></a> [do\_payloads](#input\_do\_payloads) | The Declarative Onboarding contents to apply to the instances. Required. This<br>module has migrated to use of Declarative Onboarding for module activation,<br>licensing, NTP, DNS, and other basic configurations. Sample payloads are in the<br>examples folder.<br><br>Note: if left empty, the module will use a simple JSON that sets NTP and DNS,<br>and enables LTM. | `list(string)` | `[]` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | An optional domain name to append to generated instance names to fully-qualify<br>them. | `string` | `""` | no |
| <a name="input_enable_serial_console"></a> [enable\_serial\_console](#input\_enable\_serial\_console) | Set to true to enable serial port console on the VMs. Default value is false. | `bool` | `false` | no |
| <a name="input_external_subnetwork_tier"></a> [external\_subnetwork\_tier](#input\_external\_subnetwork\_tier) | The network tier to set for external subnetwork; must be one of 'PREMIUM'<br>(default) or 'STANDARD'. | `string` | `"PREMIUM"` | no |
| <a name="input_extramb"></a> [extramb](#input\_extramb) | The amount of extra RAM (in Mb) to allocate to BIG-IP administrative processes;<br>must be an integer between 0 and 2560. The default of 2048 is recommended for<br>BIG-IP instances on GCP; setting too low can cause issues when applying DO or<br>AS3 payloads. | `number` | `2048` | no |
| <a name="input_image"></a> [image](#input\_image) | The self-link URI for a BIG-IP image to use as a base for the VM cluster. | `string` | `"projects/f5-7626-networks-public/global/images/f5-bigip-15-1-2-1-0-0-10-payg-good-25mbps-210115160742"` | no |
| <a name="input_install_cloud_libs"></a> [install\_cloud\_libs](#input\_install\_cloud\_libs) | An optional list of cloud library URLs that will be downloaded and installed on<br>the BIG-IP VM during initial boot. The contents of each download will be compared<br>to the verifyHash file, and failure will cause the boot scripts to fail. Default<br>list will install F5 Cloud Libraries (w/GCE extension), AS3, Declarative<br>Onboarding, and Telemetry Streaming extensions. | `list(string)` | <pre>[<br>  "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.25.0/f5-appsvcs-3.25.0-3.noarch.rpm",<br>  "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.18.0/f5-declarative-onboarding-1.18.0-4.noarch.rpm",<br>  "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.17.0/f5-telemetry-1.17.0-4.noarch.rpm"<br>]</pre> | no |
| <a name="input_instance_name_template"></a> [instance\_name\_template](#input\_instance\_name\_template) | A format string that will be used when naming instances. | `string` | `"bigip-%d"` | no |
| <a name="input_instance_ordinal_offset"></a> [instance\_ordinal\_offset](#input\_instance\_ordinal\_offset) | An offset to apply to each instance ordinal when naming. | `number` | `0` | no |
| <a name="input_internal_subnetwork_tier"></a> [internal\_subnetwork\_tier](#input\_internal\_subnetwork\_tier) | The network tier to set for internal subnetwork; must be one of 'PREMIUM'<br>(default) or 'STANDARD'. | `string` | `"PREMIUM"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | An optional map of *labels* to add to the instance template. | `map(string)` | `{}` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | The machine type to use for BIG-IP VMs; this may be a standard GCE machine type,<br>or a customised VM ('custom-VCPUS-MEM\_IN\_MB'). | `string` | `"n1-standard-4"` | no |
| <a name="input_management_subnetwork_tier"></a> [management\_subnetwork\_tier](#input\_management\_subnetwork\_tier) | The network tier to set for management subnetwork; must be one of 'PREMIUM'<br>(default) or 'STANDARD'. | `string` | `"PREMIUM"` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | An optional map of metadata values that will be applied to the instances. | `map(string)` | `{}` | no |
| <a name="input_min_cpu_platform"></a> [min\_cpu\_platform](#input\_min\_cpu\_platform) | An optional constraint used when scheduling the BIG-IP VMs; this value prevents<br>the VMs from being scheduled on hardware that doesn't meet the minimum CPU<br>micro-architecture. | `string` | `"Intel Skylake"` | no |
| <a name="input_modules"></a> [modules](#input\_modules) | A map of BIG-IP module = provisioning-level pairs to enable, where the module<br>name is key, and the provisioning-level is the value. This value is used with the<br>default Declaration Onboarding template; a better option for full control is to<br>explicitly declare the modules to be provisioned as part of a custom JSON file.<br>See `do_payloads`.<br><br>E.g. the default is<br>modules = {<br>  ltm = "nominal"<br>}<br><br>To provision ASM and LTM, the value might be:-<br>modules = {<br>  ltm = "nominal"<br>  asm = "nominal"<br>} | `map(string)` | <pre>{<br>  "ltm": "nominal"<br>}</pre> | no |
| <a name="input_ntp_servers"></a> [ntp\_servers](#input\_ntp\_servers) | An optional list of NTP servers for BIG-IP instances to use if custom DO files<br>are not provided. The default is ["169.254.169.254"] to use GCE metadata server. | `list(string)` | <pre>[<br>  "169.254.169.254"<br>]</pre> | no |
| <a name="input_num_instances"></a> [num\_instances](#input\_num\_instances) | The number of BIG-IP instances to provision. | `number` | `1` | no |
| <a name="input_override_admin_password_secret_manager_key"></a> [override\_admin\_password\_secret\_manager\_key](#input\_override\_admin\_password\_secret\_manager\_key) | Override the Secret Manager key for BIG-IP admin password. | `string` | `""` | no |
| <a name="input_preemptible"></a> [preemptible](#input\_preemptible) | If set to true, the BIG-IP instances will be deployed on preemptible VMs, which<br>could be terminated at any time, and have a maximum lifetime of 24 hours. | `string` | `false` | no |
| <a name="input_provision_external_public_ip"></a> [provision\_external\_public\_ip](#input\_provision\_external\_public\_ip) | If this flag is set to true (default), a publicly routable IP address WILL be<br>assigned to the external interface of instances. | `bool` | `true` | no |
| <a name="input_provision_internal_public_ip"></a> [provision\_internal\_public\_ip](#input\_provision\_internal\_public\_ip) | If this flag is set to true, a publicly routable IP address WILL be assigned to<br>the internal interfaces of instances. | `bool` | `false` | no |
| <a name="input_provision_management_public_ip"></a> [provision\_management\_public\_ip](#input\_provision\_management\_public\_ip) | If this flag is set to true, a publicly routable IP address WILL be assigned to<br>the management interface of instances. | `bool` | `false` | no |
| <a name="input_search_domains"></a> [search\_domains](#input\_search\_domains) | An optional list of DNS search domains for BIG-IP instances to use if custom DO<br>payloads are not provided. If left empty (default), search domains will be added<br>for "google.internal" and the zone/project specific domain assigned to instances. | `list(string)` | `[]` | no |
| <a name="input_secret_implementor"></a> [secret\_implementor](#input\_secret\_implementor) | The secret retrieval implementor to use; default value is an empty string.<br>Must be an empty string, 'google\_secret\_manager', or 'metadata'. Future<br>enhancements will add other implementors. | `string` | `""` | no |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | An optional set of SSH public keys, concatenated into a single string. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | An optional list of *network tags* to add to the instance template. | `list(string)` | `[]` | no |
| <a name="input_tf_sa_email"></a> [tf\_sa\_email](#input\_tf\_sa\_email) | The fully-qualified email address of the Terraform service account to use for<br>resource creation via account impersonation. If left blank, the default, then<br>the invoker's account will be used.<br><br>E.g. if you have permissions to impersonate:<br><br>tf\_sa\_email = "terraform@PROJECT\_ID.iam.gserviceaccount.com" | `string` | `""` | no |
| <a name="input_tf_sa_token_lifetime_secs"></a> [tf\_sa\_token\_lifetime\_secs](#input\_tf\_sa\_token\_lifetime\_secs) | The expiration duration for the service account token, in seconds. This value<br>should be high enough to prevent token timeout issues during resource creation,<br>but short enough that the token is useless replayed later. Default value is 600<br>(10 mins). | `number` | `600` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | The Olson timezone string from /usr/share/zoneinfo for BIG-IP instances if custom<br>DO files are not provided. The default is 'UTC'. See the TZ column here<br>(https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for legal values.<br>For example, 'US/Eastern'. | `string` | `"UTC"` | no |
| <a name="input_use_cloud_init"></a> [use\_cloud\_init](#input\_use\_cloud\_init) | If this value is set to true, cloud-init will be used as the initial<br>configuration approach. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_password_secret_manager_key"></a> [admin\_password\_secret\_manager\_key](#output\_admin\_password\_secret\_manager\_key) | The Secret Manager key for BIG-IP admin password. |
| <a name="output_alpha_net"></a> [alpha\_net](#output\_alpha\_net) | The self-link of alpha network. |
| <a name="output_alpha_subnet"></a> [alpha\_subnet](#output\_alpha\_subnet) | The self-link of alpha subnet. |
| <a name="output_beta_net"></a> [beta\_net](#output\_beta\_net) | The self-link of beta network. |
| <a name="output_beta_subnet"></a> [beta\_subnet](#output\_beta\_subnet) | The self-link of beta subnet. |
| <a name="output_delta_net"></a> [delta\_net](#output\_delta\_net) | The self-link of delta network. |
| <a name="output_delta_subnet"></a> [delta\_subnet](#output\_delta\_subnet) | The self-link of delta subnet. |
| <a name="output_epsilon_net"></a> [epsilon\_net](#output\_epsilon\_net) | The self-link of epsilon network. |
| <a name="output_epsilon_subnet"></a> [epsilon\_subnet](#output\_epsilon\_subnet) | The self-link of epsilon subnet. |
| <a name="output_eta_net"></a> [eta\_net](#output\_eta\_net) | The self-link of eta network. |
| <a name="output_eta_subnet"></a> [eta\_subnet](#output\_eta\_subnet) | The self-link of eta subnet. |
| <a name="output_external_addresses"></a> [external\_addresses](#output\_external\_addresses) | A list of the IP addresses and alias CIDRs assigned to instances on the external<br>NIC. |
| <a name="output_external_public_ips"></a> [external\_public\_ips](#output\_external\_public\_ips) | A list of the public IP addresses assigned to instances on the external NIC. |
| <a name="output_external_vips"></a> [external\_vips](#output\_external\_vips) | A list of IP CIDRs assigned to instances on the external NIC, which usually<br>corresponds to the VIPs defined on each instance. |
| <a name="output_gamma_net"></a> [gamma\_net](#output\_gamma\_net) | The self-link of gamma network. |
| <a name="output_gamma_subnet"></a> [gamma\_subnet](#output\_gamma\_subnet) | The self-link of gamma subnet. |
| <a name="output_instance_addresses"></a> [instance\_addresses](#output\_instance\_addresses) | A map of instance name to assigned IP addresses and alias CIDRs. |
| <a name="output_internal_addresses"></a> [internal\_addresses](#output\_internal\_addresses) | A list of the IP addresses and alias CIDRs assigned to instances on the internal<br>NICs, if present. |
| <a name="output_internal_public_ips"></a> [internal\_public\_ips](#output\_internal\_public\_ips) | A list of the public IP addresses assigned to instances on the internal NICs,<br>if present. |
| <a name="output_management_addresses"></a> [management\_addresses](#output\_management\_addresses) | A list of the IP addresses and alias CIDRs assigned to instances on the<br>management NIC, if present. |
| <a name="output_management_public_ips"></a> [management\_public\_ips](#output\_management\_public\_ips) | A list of the public IP addresses assigned to instances on the management NIC,<br>if present. |
| <a name="output_prefix"></a> [prefix](#output\_prefix) | The prefix prepended to generated resource names for this test. |
| <a name="output_private_addresses"></a> [private\_addresses](#output\_private\_addresses) | A list of list of private IP addresses that should be applied to the BIG-IP<br>instances. |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | The project identifier being used for testing. |
| <a name="output_public_addresses"></a> [public\_addresses](#output\_public\_addresses) | A list of list of public IP addresses that should be applied to the BIG-IP<br>instances. |
| <a name="output_region"></a> [region](#output\_region) | The compute region that will be used for BIG-IP resources. |
| <a name="output_self_links"></a> [self\_links](#output\_self\_links) | A list of self-links of the BIG-IP instances. |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | The service account to use with the BIG-IP instances. |
| <a name="output_theta_net"></a> [theta\_net](#output\_theta\_net) | The self-link of theta network. |
| <a name="output_theta_subnet"></a> [theta\_subnet](#output\_theta\_subnet) | The self-link of theta subnet. |
| <a name="output_zeta_net"></a> [zeta\_net](#output\_zeta\_net) | The self-link of zeta network. |
| <a name="output_zeta_subnet"></a> [zeta\_subnet](#output\_zeta\_subnet) | The self-link of zeta subnet. |
| <a name="output_zone_instances"></a> [zone\_instances](#output\_zone\_instances) | A map of compute zones from var.zones input variable to instance self-links. If<br>no instances are deployed to a zone, the mapping will be to an empty list. |
| <a name="output_zones"></a> [zones](#output\_zones) | The compute zones that will be used for BIG-IP instances. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
