# BIG-IP Declarative Onboarding builder sub-module

> You are viewing a **2.x release** of the modules, which supports
> **Terraform 0.13** only. *For modules compatible with Terraform 0.12, use a
> 1.x release.* Functionality is identical, but separate releases are required
> due to the difference in *variable validation* between Terraform 0.12 and 0.13.

This module encapsulates the creation of a set of DO payloads that support a very
basic configuration of BIG-IP at run-time. It is **NOT** a substitute for a custom
DO payload.

> **NOTE:** This module is unsupported and not an official F5 product. If you
> require assistance please join our
> [Slack GCP channel](https://f5cloudsolutions.slack.com/messages/gcp) and ask!

<!-- spell-checker:ignore markdownlint hostnames byol payg zoneinfo -->
<!-- markdownlint-disable MD033 MD034 -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | > 0.12 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_phone_home"></a> [allow\_phone\_home](#input\_allow\_phone\_home) | Allow the BIG-IP VMs to send high-level device use information to help F5<br>optimize development resources. If set to false the information is not sent. | `bool` | n/a | yes |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | A list of DNS servers for BIG-IP instances to use. | `list(string)` | n/a | yes |
| <a name="input_external_subnetwork_network_ips"></a> [external\_subnetwork\_network\_ips](#input\_external\_subnetwork\_network\_ips) | A list of private IP addresses that will be assigned to BIG-IP instances on their<br>external interface. The list may be empty, or contain empty strings, to selectively<br>applies addresses to instances. | `list(string)` | n/a | yes |
| <a name="input_hostnames"></a> [hostnames](#input\_hostnames) | A list of hostname declarations to set per-instance hostname in generated DO<br>payloads. If an empty list is provided, or if there are not enough names for<br>every DO payload generated, the BIG-IP hostname will not be explicitly set. | `list(string)` | n/a | yes |
| <a name="input_internal_subnetwork_network_ips"></a> [internal\_subnetwork\_network\_ips](#input\_internal\_subnetwork\_network\_ips) | A list of lists of private IP addresses to assign to BIG-IP instances on their<br>internal interface. The list may be empty, or contain empty strings, to<br>selectively apply addresses to instances. E.g. to assign addresses to two<br>internal networks:-<br><br>internal\_subnetwork\_network\_ips = [<br>  # Will be assigned to first instance<br>  [<br>    "10.0.0.4", # first internal nic<br>    "10.0.1.4", # second internal nic<br>  ],<br>  # Will be assigned to second instance<br>  [<br>    ...<br>  ],<br>  ...<br>] | `list(list(string))` | n/a | yes |
| <a name="input_modules"></a> [modules](#input\_modules) | A map of BIG-IP module = provisioning-level pairs to enable, where the module<br>name is key, and the provisioning-level is the value.<br><br>E.g.<br>modules = {<br>  ltm = "nominal"<br>}<br><br>To provision ASM and LTM, the value might be:-<br>modules = {<br>  ltm = "nominal"<br>  asm = "nominal"<br>} | `map(string)` | n/a | yes |
| <a name="input_nic_count"></a> [nic\_count](#input\_nic\_count) | The number of network interfaces that will be present in the BIG-IP VMs. | `number` | n/a | yes |
| <a name="input_ntp_servers"></a> [ntp\_servers](#input\_ntp\_servers) | A list of NTP servers for BIG-IP instances to use. | `list(string)` | n/a | yes |
| <a name="input_num_instances"></a> [num\_instances](#input\_num\_instances) | The number of DO payloads to generate. | `number` | n/a | yes |
| <a name="input_search_domains"></a> [search\_domains](#input\_search\_domains) | A list of DNS search domains for BIG-IP instances to use. | `list(string)` | n/a | yes |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | The Olson timezone string from /usr/share/zoneinfo for BIG-IP instances. See the<br>TZ column here (https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for<br>legal values. For example, 'US/Eastern'. | `string` | n/a | yes |
| <a name="input_additional_configs"></a> [additional\_configs](#input\_additional\_configs) | A list of additional DO configuration snippets JSON to merge with the generated<br>payloads. Any JSON provided here will be inserted as-is into the "Common" object<br>after any self IPs, routes, etc. Entries will not be merged or validated.<br><br>E.g. to add a new self IP to each generated payload:<br><br>additional\_configs = [<br>  "\"extra-self\": {<br>    \"class\": \"SelfIp\",<br>    \"address\": \"1.2.3.4/32\",<br>    ...<br>  }",<br>  ...<br>] | `list(string)` | `[]` | no |
| <a name="input_allow_service"></a> [allow\_service](#input\_allow\_service) | A map of 'allowService' values to apply to named DO interfaces. If an specific<br>value is not found for an interface, the value 'none' shall be applied to internal<br>interfaces, and default to external.<br><br>E.g. to allow default service on internal but none on external interfaces:<br>allow\_service = {<br>  external = "none"<br>  internal = "default"<br>} | `map(string)` | `{}` | no |
| <a name="input_default_gateway"></a> [default\_gateway](#input\_default\_gateway) | Set this to the value to use as the default gateway for BIG-IP instances. This<br>must be a valid IP address or an empty string. If left blank (default), the<br>generated Declarative Onboarding JSON will use the gateway associated with nic0<br>at run-time. | `string` | `""` | no |
| <a name="input_extramb"></a> [extramb](#input\_extramb) | The amount of extra RAM (in Mb) to allocate to BIG-IP administrative processes;<br>must be an integer between 0 and 2560. The default of 2048 is recommended for<br>BIG-IP instances on GCP; setting too low can cause issues when applying large DO<br>or AS3 payloads. | `number` | `2048` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_do_payloads"></a> [do\_payloads](#output\_do\_payloads) | A list of generated Declarative Onboarding JSON payloads. |
| <a name="output_jq_filter"></a> [jq\_filter](#output\_jq\_filter) | A JQ filter that can replace missing IP addresss, networks, and MTUs in DO<br>payload generated from this module. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
