# Unofficial F5 BIG-IP Terraform modules for Google Cloud Platform

> You are viewing a **2.x release** of the modules, which supports
> **Terraform 0.13 and 0.14** only. *For modules compatible with Terraform 0.12,
> use a 1.x release.* Functionality is identical, but separate releases are
> required due to the difference in *variable validation* between Terraform 0.12
> and 0.13+.

<!-- spell-checker:ignore markdownlint -->
<!-- markdownlint-disable MD033 -->
This repo contains unofficial and unsupported<sup>1</sup> Terraform modules to
deploy F5 BIG-IP Virtual Edition on Google Cloud Platform, using a modular
approach that can be composed into a solution that is consistent for each variant
of a product.
<!-- markdownlint-enable MD033 -->

> *TIP:* If you require assistance please join our
> [Slack GCP channel](https://f5cloudsolutions.slack.com/messages/gcp) and ask!

These modules support deploying supported BIG-IP versions instances to Google
Cloud in an opinionated manner. By themselves they do not implement a full stack
or solution, and additional setup will be needed for firewall rules, service
account creation and role assignments.

> **NOTE:** The modules do not include setup and configuration of supporting
> resources, such as ingress firewall rules or service accounts. Where required,
> the examples will include the bare-minimum setup to demonstrate usage.

Examples are provided for standalone, HA and CFE deployments.

## Rationale

The intent is allow for integration of BIG-IP with GCP infrastructure that is
managed using Google's
[Cloud Foundation Toolkit](https://cloud.google.com/foundation-toolkit)
Terraform modules or an equivalent. The modules here are not fully-baked
solutions, but can be integrated with foundational elements to build a reusable
deployment pipeline.

For example, the modules do not include ingress firewall rule resources as core
module components. This is because some organizations may mandate use of service
account based rules, where others prefer tag based, or a combination of both where
interfaces are attached to peered VPCs. The exception to this is the firewall
module to support ConfigSync for HA and CFE clusters; since the BIG-IPs will be
deployed to the same VPC networks, it is reasonably safe to assume a service
account based rule will be universally applicable.

## BIG-IP module options

The BIG-IP module will create standalone BIG-IP VMs that include default
[AS3](https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/)
and [DO](https://clouddocs.f5.com/products/extensions/f5-declarative-onboarding/latest/)
declarations (unless overridden). The sub-modules extend the standalone
functionality while retaining an the same API (implemented as Terraform input
variables) where possible. This promotes consistency and reuse when your project
calls for a CFE or Autoscaling approach. For more information about these see
the README files in each sub-module.

<!-- spell-checker: ignore configsync  -->
* Standalone BIG-IP instances
  * Support 1-8 network interfaces
  * Opinionated startup scripts
  * Override default gateway when needed; e.g. for bootstrapping in a restricted
     VPC where data-plane does not have egress
  * [Applications Services 3](https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/) extension support
  * [Declarative Onboarding](https://clouddocs.f5.com/products/extensions/f5-declarative-onboarding/latest/) extension support
* High-availability BIG-IP clusters
  * **configsync-fw** helper sub-module to create required firewall rules for ConfigSync on control and data-plane networks
  * [Cloud Failover Extension](https://clouddocs.f5.com/products/extensions/f5-cloud-failover/latest/) support
  * **cfe-role** helper sub-module to create a custom role which satisfies the
    minimum privileges required for CFE to interact with GCP APIs

## Dependencies

The BIG-IP modules all have a common set of requirements.

1. Terraform 0.13.x or 0.14.x

   > You are viewing a **2.x release** of the modules, which supports
   > **Terraform 0.13 or 0.14** only. *For modules compatible with Terraform 0.12,
   > use a 1.x release.* Functionality is identical, but separate releases are required
   > due to the difference in *variable validation* between Terraform 0.12 and 0.13+.

2. Google Cloud [Secret Manager](https://cloud.google.com/secret-manager)

   There are many good options for run-time secret injection but this module is
   supporting Google's Secret Manager only at this time.

3. APIs to enable

   * Compute Engine `compute.googleapis.com`
   <!-- spell-checker: ignore secretmanager  -->
   * Secret Manager `secretmanager.googleapis.com`
   * Storage (required for CFE) `storage-api.googleapis.com`

## Run-time setup

The BIG-IP modules in this repo support [cloud-init](https://cloudinit.readthedocs.io/en/latest/)
and [metadata-startup-script](https://cloud.google.com/compute/docs/startupscript)
boot options, defaulting to the metadata startup-script for compatibility with
BIG-IP versions 13.x, 14.x, and 15.x. Set the `use_cloud_init` input variable to
`true` to force the use of cloud-init on BIG-IP v15+.

Fundamentally both approaches launch the same shell scripts; the difference is
that `cloud-init` script installs a systemd service unit with dependencies to
prevent early execution, and automatically disables the service unit after
success. The simple metadata startup-script will execute on every boot.

For more information on how run-time configuration is applied to each BIG-IP
instance through the use of Terraform variables see
[CONFIGURATION](https://github.com/memes/terraform-google-f5-bigip/blob/main/CONFIGURATION.md).
For guidelines and steps to diagnose deployment and run-time issues see
[TROUBLESHOOTING](https://github.com/memes/terraform-google-f5-bigip/blob/main/TROUBLESHOOTING.md).

<!-- spell-checker: ignore bigip oslogin nics byol payg vcpus preemptible routable zoneinfo -->
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
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.48 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_do_payloads"></a> [do\_payloads](#module\_do\_payloads) | f5devcentral/do-builder/bigip | 1.0.0-rc1 |
| <a name="module_metadata"></a> [metadata](#module\_metadata) | ./modules/metadata/ |  |

## Resources

| Name | Type |
|------|------|
| [google_compute_instance.bigip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password_secret_manager_key"></a> [admin\_password\_secret\_manager\_key](#input\_admin\_password\_secret\_manager\_key) | The Secret Manager key for BIG-IP admin password; during initialisation, the<br>BIG-IP admin account's password will be changed to the value retrieved from GCP<br>Secret Manager (or other implementor - see `secret_implementor`) using this key.<br><br>NOTE: if the secret does not exist, is misidentified, or if the VM cannot read<br>the secret value associated with this key, then the BIG-IP onboarding will fail<br>to complete, and onboarding will require manual intervention. | `string` | n/a | yes |
| <a name="input_external_subnetwork"></a> [external\_subnetwork](#input\_external\_subnetwork) | The fully-qualified self-link of the subnet that will be used for external ingress<br>(2+ NIC deployment), or for all traffic in a 1NIC deployment. | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | The self-link URI for a BIG-IP image to use as a base for the VM cluster. This<br>can be an official F5 image from GCP Marketplace, or a customised image. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project identifier where the cluster will be created. | `string` | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | The service account that will be used for the BIG-IP VMs. | `string` | n/a | yes |
| <a name="input_zones"></a> [zones](#input\_zones) | The compute zones which will host the BIG-IP VMs. | `list(string)` | n/a | yes |
| <a name="input_allow_phone_home"></a> [allow\_phone\_home](#input\_allow\_phone\_home) | Allow the BIG-IP VMs to send high-level device use information to help F5<br>optimize development resources. If set to false the information is not sent. | `bool` | `true` | no |
| <a name="input_as3_payloads"></a> [as3\_payloads](#input\_as3\_payloads) | An optional, but recommended, list of AS3 JSON files that can be used to setup<br>the BIG-IP instances. If left empty (default), the module will use a simple<br>no-op AS3 declaration. | `list(string)` | `[]` | no |
| <a name="input_automatic_restart"></a> [automatic\_restart](#input\_automatic\_restart) | Determines if the BIG-IP VMs should be automatically restarted if terminated by<br>GCE. Defaults to true to match expected GCE behaviour. | `bool` | `true` | no |
| <a name="input_custom_script"></a> [custom\_script](#input\_custom\_script) | An optional, custom shell script that will be executed during BIG-IP<br>initialisation, after BIG-IP networking is auto-configured, admin password is set from Secret<br>Manager (if possible), etc. Declarative Onboarding offers a better approach,<br>where suitable (see `do_payload`).<br><br>NOTE: this value should contain the script contents, not a file path. | `string` | `""` | no |
| <a name="input_default_gateway"></a> [default\_gateway](#input\_default\_gateway) | Set this to the value to use as the default gateway for BIG-IP instances. This<br>must be a valid IP address or an empty string. If left blank (default), the<br>generated Declarative Onboarding JSON will use the gateway associated with nic0<br>at run-time. | `string` | `""` | no |
| <a name="input_delete_disk_on_destroy"></a> [delete\_disk\_on\_destroy](#input\_delete\_disk\_on\_destroy) | Set this flag to false if you want the boot disk associated with the launched VMs<br>to survive when instances are destroyed. The default value of true will ensure the<br>boot disk is destroyed when the instance is destroyed. | `bool` | `true` | no |
| <a name="input_disk_size_gb"></a> [disk\_size\_gb](#input\_disk\_size\_gb) | Use this flag to set the boot volume size in GB. If left at the default value<br>the boot disk will have the same size as specified in 'bigip\_image'. | `number` | `null` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | The boot disk type to use with instances; can be 'pd-ssd' (default), or<br>'pd-standard'.<br>*Note:* Choosing 'pd-standard' will reduce operating cost, but at the expense of<br>network performance. | `string` | `"pd-ssd"` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | An optional list of DNS servers for BIG-IP instances to use if custom DO payloads<br>are not provided. The default is ["169.254.169.254"] to use GCE metadata server. | `list(string)` | <pre>[<br>  "169.254.169.254"<br>]</pre> | no |
| <a name="input_do_payloads"></a> [do\_payloads](#input\_do\_payloads) | The Declarative Onboarding contents to apply to the instances. Required. This<br>module has migrated to use of Declarative Onboarding for module activation,<br>licensing, NTP, DNS, and other basic configurations. Sample payloads are in the<br>examples folder.<br><br>Note: if left empty, the module will use a simple JSON that sets NTP and DNS,<br>and enables LTM. | `list(string)` | `[]` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | An optional domain name to append to generated instance names to fully-qualify<br>them. If an empty string (default), then the instances will be qualified as-per<br>Google Cloud internal naming conventions ".ZONE.c.PROJECT\_ID.internal". | `string` | `""` | no |
| <a name="input_enable_serial_console"></a> [enable\_serial\_console](#input\_enable\_serial\_console) | Set to true to enable serial port console on the VMs. Default value is false. | `bool` | `false` | no |
| <a name="input_external_subnetwork_network_ips"></a> [external\_subnetwork\_network\_ips](#input\_external\_subnetwork\_network\_ips) | An optional list of private IP addresses to assign to BIG-IP instances on their<br>externa interface. The list may be empty, or contain empty strings, to selectively<br>applies addresses to instances. | `list(string)` | `[]` | no |
| <a name="input_external_subnetwork_public_ips"></a> [external\_subnetwork\_public\_ips](#input\_external\_subnetwork\_public\_ips) | An optional list of public IP addresses to assign to BIG-IP instances on their<br>external interface. The list may be empty, or contain empty strings, to selectively<br>applies addresses to instances.<br><br>Note: these values are only applied if `provision_external_public_ip` is 'true'<br>and will be ignored if that value is false. | `list(string)` | `[]` | no |
| <a name="input_external_subnetwork_tier"></a> [external\_subnetwork\_tier](#input\_external\_subnetwork\_tier) | The network tier to set for external subnetwork; must be one of 'PREMIUM'<br>(default) or 'STANDARD'. This setting only applies if the external interface is<br>permitted to have a public IP address (see `provision_external_public_ip`) | `string` | `"PREMIUM"` | no |
| <a name="input_external_subnetwork_vip_cidrs"></a> [external\_subnetwork\_vip\_cidrs](#input\_external\_subnetwork\_vip\_cidrs) | An optional list of VIP CIDR lists to assign to BIG-IP instances on their<br>external interface. E.g. to assign two CIDR blocks as VIPs on the first instance,<br>and a single IP address as a VIP on the second instance:-<br><br>external\_subnetwork\_vip\_cidrs = [<br>  [<br>    "10.1.0.0/16",<br>    "10.2.0.0/24",<br>  ],<br>  [<br>    "192.168.0.1/32",<br>  ]<br>] | `list(list(string))` | `[]` | no |
| <a name="input_external_subnetwork_vip_cidrs_named_range"></a> [external\_subnetwork\_vip\_cidrs\_named\_range](#input\_external\_subnetwork\_vip\_cidrs\_named\_range) | An optional named range to use when assigning CIDRs to BIG-IP instances as VIPs<br>on their external interface. E.g. to assign CIDRs from<br>secondary range 'dmz-bigip':-<br><br>external\_subnetwork\_vip\_cidrs\_named\_range = "dmz-bigip" | `string` | `""` | no |
| <a name="input_extramb"></a> [extramb](#input\_extramb) | The amount of extra RAM (in Mb) to allocate to BIG-IP administrative processes;<br>must be an integer between 0 and 2560. The default of 2048 is recommended for<br>BIG-IP instances on GCP; setting too low can cause issues when applying large DO<br>or AS3 payloads. | `number` | `2048` | no |
| <a name="input_install_cloud_libs"></a> [install\_cloud\_libs](#input\_install\_cloud\_libs) | An optional list of cloud library URLs that will be downloaded and installed on<br>the BIG-IP VM during initial boot. The contents of each download will be compared<br>to the verifyHash file, and failure will cause the boot scripts to fail. Default<br>list will install F5 Cloud Libraries (w/GCE extension), AS3, Declarative<br>Onboarding, and Telemetry Streaming extensions. | `list(string)` | <pre>[<br>  "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.25.0/f5-appsvcs-3.25.0-3.noarch.rpm",<br>  "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.18.0/f5-declarative-onboarding-1.18.0-4.noarch.rpm",<br>  "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.17.0/f5-telemetry-1.17.0-4.noarch.rpm"<br>]</pre> | no |
| <a name="input_instance_name_template"></a> [instance\_name\_template](#input\_instance\_name\_template) | A format string that will be used when naming instance, that should include a<br>format token for including integer ordinal numbers as defined in Go `fmt` package,<br>including support for zero-padding etc. Default value is 'bigip-%d' which will<br>generate names of 'bigip-0', 'bigip-1', through 'bigip-N', where N is the number<br>of instances - 1.<br><br>Examples:<br>instance\_name\_template = "bigip-%03d" will create instances named 'bigip-000',<br>'bigip-001', etc.<br>instance\_name\_template = "prod-ha-%x" will create instances using lower-case hex<br>, such as 'prod-ha-0' ... 'prod-ha-1f'.<br><br>See `instance_ordinal_offset` variable to change the lower bounds of the numbering<br>scheme. | `string` | `"bigip-%d"` | no |
| <a name="input_instance_ordinal_offset"></a> [instance\_ordinal\_offset](#input\_instance\_ordinal\_offset) | An offset to apply to each instance ordinal when naming; use to change zero-based<br>instance ordinal to a different number when setting instance names and hostnames.<br>Default value is '0'.<br><br>E.g. to change 0-based instance names ('bigip-0', 'bigip-1', etc.) to 1-based<br>instance names ('bigip-1', 'bigip-2', etc.) use<br>instance\_ordinal\_offset = 1<br><br>See `instance_name_template` for more examples. | `number` | `0` | no |
| <a name="input_internal_subnetwork_network_ips"></a> [internal\_subnetwork\_network\_ips](#input\_internal\_subnetwork\_network\_ips) | An optional list of lists of private IP addresses to assign to BIG-IP instances<br>on their internal interface. The list may be empty, or contain empty strings, to<br>selectively applies addresses to instances. E.g. to assign addresses to two<br>internal networks:<br><br>internal\_subnetwork\_network\_ips = [<br>  # Will be assigned to first instance<br>  [<br>    "10.0.0.4", # first internal nic<br>    "10.0.1.4", # second internal nic<br>  ],<br>  # Will be assigned to second instance<br>  [<br>    ...<br>  ],<br>  ...<br>] | `list(list(string))` | `[]` | no |
| <a name="input_internal_subnetwork_public_ips"></a> [internal\_subnetwork\_public\_ips](#input\_internal\_subnetwork\_public\_ips) | An optional list of lists of public IP addresses to assign to BIG-IP instances<br>on their internal interface. The list may be empty, or contain empty strings, to<br>selectively applies addresses to instances.<br><br>Note: these values are only applied if `provision_internal_public_ip` is 'true'<br>and will be ignored if that value is false.<br><br>E.g. to assign addresses to two internal networks:<br><br>internal\_subnetwork\_network\_ips = [<br>  # Will be assigned to first instance<br>  [<br>    "x.x.x.x", # first internal nic<br>    "y.y.y.y", # second internal nic<br>  ],<br>  # Will be assigned to second instance<br>  [<br>    ...<br>  ],<br>  ...<br>] | `list(list(string))` | `[]` | no |
| <a name="input_internal_subnetwork_tier"></a> [internal\_subnetwork\_tier](#input\_internal\_subnetwork\_tier) | The network tier to set for internal subnetwork; must be one of 'PREMIUM'<br>(default) or 'STANDARD'. This setting only applies if the internal interface is<br>permitted to have a public IP address (see `provision_internal_public_ip`) | `string` | `"PREMIUM"` | no |
| <a name="input_internal_subnetwork_vip_cidrs"></a> [internal\_subnetwork\_vip\_cidrs](#input\_internal\_subnetwork\_vip\_cidrs) | An optional list of CIDR lists to assign to BIG-IP instances as VIPs on their<br>internal interface. E.g. to assign two CIDR blocks as VIPs on the first<br>instance, and a single IP address as a VIP on the second instance:-<br><br>internal\_subnetwork\_vip\_cidrs = [<br>  # Will be assigned to first instance<br>  [<br>    ["10.1.0.0/16"], # first internal nic<br>    ["10.2.0.0/24"], # second internal nic<br>  ],<br>  # Will be assigned to second instance<br>  [<br>    ["192.168.0.1/32"], # first internal nic<br>  ]<br>] | `list(list(list(string)))` | `[]` | no |
| <a name="input_internal_subnetwork_vip_cidrs_named_ranges"></a> [internal\_subnetwork\_vip\_cidrs\_named\_ranges](#input\_internal\_subnetwork\_vip\_cidrs\_named\_ranges) | An optional named range to use when assigning CIDRs to BIG-IP instances as VIPs<br>on their internal interfaces. E.g. to assign CIDRs from<br>secondary range 'internal-bigip' on first internal interface:-<br><br>internal\_subnetwork\_vip\_cidrs\_named\_ranges = [<br>  "internal-bigip",<br>] | `list(string)` | `[]` | no |
| <a name="input_internal_subnetworks"></a> [internal\_subnetworks](#input\_internal\_subnetworks) | An optional list of fully-qualified subnet self-links that will be assigned as<br>internal traffic on NICs eth[2-8]. | `list(string)` | `[]` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | An optional map of *labels* to add to the instance template. | `map(string)` | `{}` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | The machine type to use for BIG-IP VMs; this may be a standard GCE machine type,<br>or a customised VM ('custom-VCPUS-MEM\_IN\_MB'). Default value is 'n1-standard-4'.<br>*Note:* machine\_type is highly-correlated with network bandwidth and performance;<br>an N2 or N2D machine type will give better performance but has limited availability. | `string` | `"n1-standard-4"` | no |
| <a name="input_management_subnetwork"></a> [management\_subnetwork](#input\_management\_subnetwork) | An optional fully-qualified self-link of the subnet that will be used for<br>management access (2+ NIC deployment). | `string` | `null` | no |
| <a name="input_management_subnetwork_network_ips"></a> [management\_subnetwork\_network\_ips](#input\_management\_subnetwork\_network\_ips) | An optional list of private IP addresses to assign to BIG-IP instances on their<br>management interface. The list may be empty, or contain empty strings, to<br>selectively applies addresses to instances. | `list(string)` | `[]` | no |
| <a name="input_management_subnetwork_public_ips"></a> [management\_subnetwork\_public\_ips](#input\_management\_subnetwork\_public\_ips) | An optional list of public IP addresses to assign to BIG-IP instances on their<br>management interface. The list may be empty, or contain empty strings, to<br>selectively applies addresses to instances.<br><br>Note: these values are only applied if `provision_management_public_ip` is 'true'<br>and will be ignored if that value is false. | `list(string)` | `[]` | no |
| <a name="input_management_subnetwork_tier"></a> [management\_subnetwork\_tier](#input\_management\_subnetwork\_tier) | The network tier to set for management subnetwork; must be one of 'PREMIUM'<br>(default) or 'STANDARD'. This setting only applies if the management interface is<br>permitted to have a public IP address (see `provision_management_public_ip`) | `string` | `"PREMIUM"` | no |
| <a name="input_management_subnetwork_vip_cidrs"></a> [management\_subnetwork\_vip\_cidrs](#input\_management\_subnetwork\_vip\_cidrs) | An optional list of CIDR lists to assign to BIG-IP instances as VIPs on their<br>management interface. E.g. to assign two CIDR blocks as VIPs on the first<br>instance, and a single IP address as an alias on the second instance:-<br><br>external\_subnetwork\_vip\_cidrs = [<br>  [<br>    "10.1.0.0/16",<br>    "10.2.0.0/24",<br>  ],<br>  [<br>    "192.168.0.1/32",<br>  ]<br>] | `list(list(string))` | `[]` | no |
| <a name="input_management_subnetwork_vip_cidrs_named_range"></a> [management\_subnetwork\_vip\_cidrs\_named\_range](#input\_management\_subnetwork\_vip\_cidrs\_named\_range) | An optional named range to use when assigning CIDRs to BIG-IP instances as VIPs<br>on their management interface. E.g. to assign CIDRs from<br>secondary range 'management-bigip':-<br><br>management\_subnetwork\_vip\_cidrs\_named\_range = "management-bigip" | `string` | `""` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | An optional map of metadata values that will be applied to the instances. | `map(string)` | `{}` | no |
| <a name="input_min_cpu_platform"></a> [min\_cpu\_platform](#input\_min\_cpu\_platform) | An optional constraint used when scheduling the BIG-IP VMs; this value prevents<br>the VMs from being scheduled on hardware that doesn't meet the minimum CPU<br>micro-architecture. Default value is 'Intel Skylake'. | `string` | `"Intel Skylake"` | no |
| <a name="input_modules"></a> [modules](#input\_modules) | A map of BIG-IP module = provisioning-level pairs to enable, where the module<br>name is key, and the provisioning-level is the value. This value is used with the<br>default Declaration Onboarding template; a better option for full control is to<br>explicitly declare the modules to be provisioned as part of a custom JSON file.<br>See `do_payloads`.<br><br>E.g. the default is<br>modules = {<br>  ltm = "nominal"<br>}<br><br>To provision ASM and LTM, the value might be:-<br>modules = {<br>  ltm = "nominal"<br>  asm = "nominal"<br>} | `map(string)` | <pre>{<br>  "ltm": "nominal"<br>}</pre> | no |
| <a name="input_ntp_servers"></a> [ntp\_servers](#input\_ntp\_servers) | An optional list of NTP servers for BIG-IP instances to use if custom DO files<br>are not provided. The default is ["169.254.169.254"] to use GCE metadata server. | `list(string)` | <pre>[<br>  "169.254.169.254"<br>]</pre> | no |
| <a name="input_num_instances"></a> [num\_instances](#input\_num\_instances) | The number of standalone BIG-IP instances to provision. Default value is 1. | `number` | `1` | no |
| <a name="input_preemptible"></a> [preemptible](#input\_preemptible) | If set to true, the BIG-IP instances will be deployed on preemptible VMs, which<br>could be terminated at any time, and have a maximum lifetime of 24 hours. Default<br>value is false. | `string` | `false` | no |
| <a name="input_provision_external_public_ip"></a> [provision\_external\_public\_ip](#input\_provision\_external\_public\_ip) | If this flag is set to true (default), a publicly routable IP address WILL be<br>assigned to the external interface of instances. If set to false, the BIG-IP<br>instances will NOT have a public IP address assigned to the external interface. | `bool` | `true` | no |
| <a name="input_provision_internal_public_ip"></a> [provision\_internal\_public\_ip](#input\_provision\_internal\_public\_ip) | If this flag is set to true, a publicly routable IP address WILL be assigned to<br>the internal interfaces of instances. If set to false (default), the BIG-IP<br>instances will NOT have a public IP address assigned to the internal interfaces. | `bool` | `false` | no |
| <a name="input_provision_management_public_ip"></a> [provision\_management\_public\_ip](#input\_provision\_management\_public\_ip) | If this flag is set to true, a publicly routable IP address WILL be assigned to<br>the management interface of instances. If set to false (default), the BIG-IP<br>instances will NOT have a public IP address assigned to the management interface. | `bool` | `false` | no |
| <a name="input_search_domains"></a> [search\_domains](#input\_search\_domains) | An optional list of DNS search domains for BIG-IP instances to use if custom DO<br>payloads are not provided. If left empty (default), search domains will be added<br>for "google.internal" and the zone/project specific domain assigned to instances. | `list(string)` | `[]` | no |
| <a name="input_secret_implementor"></a> [secret\_implementor](#input\_secret\_implementor) | The secret retrieval implementor to use; default value is an empty string.<br>Must be an empty string, 'google\_secret\_manager', or 'metadata'. Future<br>enhancements will add other implementors. | `string` | `""` | no |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | An optional set of SSH public keys, concatenated into a single string. The keys<br>will be added to instance metadata. Default is an empty string. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | An optional list of *network tags* to add to the instance template. | `list(string)` | `[]` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | The Olson timezone string from /usr/share/zoneinfo for BIG-IP instances if custom<br>DO files are not provided. The default is 'UTC'. See the TZ column here<br>(https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for legal values.<br>For example, 'US/Eastern'. | `string` | `"UTC"` | no |
| <a name="input_use_cloud_init"></a> [use\_cloud\_init](#input\_use\_cloud\_init) | If this value is set to true, cloud-init will be used as the initial<br>configuration approach; false (default) will fall-back to a standard shell<br>script for boot-time configuration.<br><br>Note: the BIG-IP version must support Cloud Init on GCP for this to function<br>correctly. E.g. v15.1+. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_external_addresses"></a> [external\_addresses](#output\_external\_addresses) | A list of the IP addresses and alias CIDRs assigned to instances on the external<br>NIC. |
| <a name="output_external_public_ips"></a> [external\_public\_ips](#output\_external\_public\_ips) | A list of the public IP addresses assigned to instances on the external NIC. |
| <a name="output_external_vips"></a> [external\_vips](#output\_external\_vips) | A list of IP CIDRs assigned to instances on the external NIC, which usually<br>corresponds to the VIPs defined on each instance. |
| <a name="output_instance_addresses"></a> [instance\_addresses](#output\_instance\_addresses) | A map of instance name to assigned IP addresses and alias CIDRs. |
| <a name="output_internal_addresses"></a> [internal\_addresses](#output\_internal\_addresses) | A list of the IP addresses and alias CIDRs assigned to instances on the internal<br>NICs, if present. |
| <a name="output_internal_public_ips"></a> [internal\_public\_ips](#output\_internal\_public\_ips) | A list of the public IP addresses assigned to instances on the internal NICs,<br>if present. |
| <a name="output_management_addresses"></a> [management\_addresses](#output\_management\_addresses) | A list of the IP addresses and alias CIDRs assigned to instances on the<br>management NIC, if present. |
| <a name="output_management_public_ips"></a> [management\_public\_ips](#output\_management\_public\_ips) | A list of the public IP addresses assigned to instances on the management NIC,<br>if present. |
| <a name="output_self_links"></a> [self\_links](#output\_self\_links) | A list of self-links of the BIG-IP instances. |
| <a name="output_zone_instances"></a> [zone\_instances](#output\_zone\_instances) | A map of compute zones from var.zones input variable to instance self-links. If<br>no instances are deployed to a zone, the mapping will be to an empty list.<br><br>E.g. if `var.zones = ["us-east1-a", "us-east1-b", "us-east1-c"]` and<br>`var.num_instances = 2` then the output will be:<br>{<br>  us-east1-a = [self-link-instance0]<br>  us-east1-b = [self-link-instance1]<br>  us-east1-c = []<br>} |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->

---

<!-- markdownlint-disable MD033 -->
<sup>1</sup>This repo will be maintained on a best-effort basis, but is not a
substitute for F5 support.
<!-- markdownlint-enable MD033 -->
