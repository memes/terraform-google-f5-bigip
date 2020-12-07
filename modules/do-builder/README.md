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
| terraform | > 0.12 |

## Providers

No provider.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_config | A map of additional configuration parameters to add to the generated JSON. | `map(any)` | `{}` | no |
| allow\_phone\_home | Allow the BIG-IP VMs to send high-level device use information to help F5<br>optimize development resources. If set to false the information is not sent. | `bool` | n/a | yes |
| dns\_servers | A list of DNS servers for BIG-IP instances to use. | `list(string)` | n/a | yes |
| external\_subnetwork\_network\_ips | A list of IP addresses that will be assigned to BIG-IP instances on their external<br>interface. The list may be empty, or contain empty strings, to selectively<br>applies addresses to instances. | `list(string)` | n/a | yes |
| external\_subnetwork\_vip\_cidrs | A list of VIP CIDR lists to assign to BIG-IP instances on their<br>external interface. E.g. to assign two CIDR blocks as VIPs on the first instance,<br>and a single IP address as a VIP on the second instance:-<br><br>external\_subnetwork\_vip\_cidrs = [<br>  [<br>    "10.1.0.0/16",<br>    "10.2.0.0/24",<br>  ],<br>  [<br>    "192.168.0.1/32",<br>  ]<br>] | `list(list(string))` | n/a | yes |
| hostnames | A list of hostname declarations to set per-instance hostname in generated DO<br>payloads. If an empty list is provided, or if there are not enough names for<br>every DO payload generated, the BIG-IP hostname will not be explicitly set. | `list(string)` | n/a | yes |
| internal\_nic\_count | The number of internal network interfaces that will be present in the BIG-IP VMs. | `number` | n/a | yes |
| internal\_subnetwork\_network\_ips | A list of lists of IP addresses to assign to BIG-IP instances on their internal<br>interface. The list may be empty, or contain empty strings, to selectively apply<br>addresses to instances. E.g. to assign addresses to two<br>internal networks:-<br><br>internal\_subnetwork\_network\_ips = [<br>  # Will be assigned to first instance<br>  [<br>    "10.0.0.4", # first internal nic<br>    "10.0.1.4", # second internal nic<br>  ],<br>  # Will be assigned to second instance<br>  [<br>    ...<br>  ],<br>  ...<br>] | `list(list(string))` | n/a | yes |
| internal\_subnetwork\_vip\_cidrs | A list of CIDR lists to assign to BIG-IP instances as VIPs on their internal<br>interface. E.g. to assign two CIDR blocks as VIPs on the first instance, and a<br>single IP address as a VIP on the second instance:-<br><br>internal\_subnetwork\_vip\_cidrs = [<br>  # Will be assigned to first instance<br>  [<br>    "10.1.0.0/16", # first internal nic<br>    "10.2.0.0/24", # second internal nic<br>  ],<br>  # Will be assigned to second instance<br>  [<br>    "192.168.0.1/32", # first internal nic<br>  ]<br>] | `list(list(string))` | n/a | yes |
| modules | A map of BIG-IP module = provisioning-level pairs to enable, where the module<br>name is key, and the provisioning-level is the value.<br><br>E.g.<br>modules = {<br>  ltm = "nominal"<br>}<br><br>To provision ASM and LTM, the value might be:-<br>modules = {<br>  ltm = "nominal"<br>  asm = "nominal"<br>} | `map(string)` | n/a | yes |
| ntp\_servers | A list of NTP servers for BIG-IP instances to use. | `list(string)` | n/a | yes |
| num\_instances | The number of DO payloads to generate. | `number` | n/a | yes |
| provision\_external\_public\_ip | If this flag is set to true, a publicly routable IP address WILL be assigned to<br>the external interface of instances. If set to false, the BIG-IP<br>instances will NOT have a public IP address assigned to the external interface. | `bool` | n/a | yes |
| provision\_internal\_public\_ip | If this flag is set to true, a publicly routable IP address WILL be assigned to<br>the internal interfaces of instances. If set to false, the BIG-IP instances will<br>NOT have a public IP address assigned to the internal interfaces. | `bool` | n/a | yes |
| search\_domains | A list of DNS search domains for BIG-IP instances to use. | `list(string)` | n/a | yes |
| timezone | The Olson timezone string from /usr/share/zoneinfo for BIG-IP instances. See the<br>TZ column here (https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for<br>legal values. For example, 'US/Eastern'. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| do\_payloads | A list of generated Declarative Onboarding JSON payloads. |
| jq\_filter | A JQ filter that can replace missing IP addresss, networks, and MTUs in DO<br>payload generated from this module. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 MD034 -->
