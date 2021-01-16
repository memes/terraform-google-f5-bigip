variable "num_instances" {
  type        = number
  description = <<EOD
The number of DO payloads to generate.
EOD
}

variable "ntp_servers" {
  type        = list(string)
  description = <<EOD
A list of NTP servers for BIG-IP instances to use.
EOD
}

variable "timezone" {
  type        = string
  description = <<EOD
The Olson timezone string from /usr/share/zoneinfo for BIG-IP instances. See the
TZ column here (https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for
legal values. For example, 'US/Eastern'.
EOD
}

variable "modules" {
  type        = map(string)
  description = <<EOD
A map of BIG-IP module = provisioning-level pairs to enable, where the module
name is key, and the provisioning-level is the value.

E.g.
modules = {
  ltm = "nominal"
}

To provision ASM and LTM, the value might be:-
modules = {
  ltm = "nominal"
  asm = "nominal"
}
EOD
}

variable "allow_phone_home" {
  type        = bool
  description = <<EOD
Allow the BIG-IP VMs to send high-level device use information to help F5
optimize development resources. If set to false the information is not sent.
EOD
}

variable "hostnames" {
  type        = list(string)
  description = <<EOD
A list of hostname declarations to set per-instance hostname in generated DO
payloads. If an empty list is provided, or if there are not enough names for
every DO payload generated, the BIG-IP hostname will not be explicitly set.
EOD
}

variable "dns_servers" {
  type        = list(string)
  description = <<EOD
A list of DNS servers for BIG-IP instances to use.
EOD
}

variable "search_domains" {
  type        = list(string)
  description = <<EOD
A list of DNS search domains for BIG-IP instances to use.
EOD
}

variable "nic_count" {
  type        = number
  description = <<EOD
The number of network interfaces that will be present in the BIG-IP VMs.
EOD
}

variable "provision_external_public_ip" {
  type        = bool
  description = <<EOD
If this flag is set to true, a publicly routable IP address WILL be assigned to
the external interface of instances. If set to false, the BIG-IP
instances will NOT have a public IP address assigned to the external interface.
EOD
}

variable "external_subnetwork_network_ips" {
  type = list(string)
  validation {
    condition     = length(join("", [for ip in var.external_subnetwork_network_ips : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", ip)) ? "x" : ""])) == length(var.external_subnetwork_network_ips)
    error_message = "Each external_subnetwork_network_ips value must be a valid IPv4 address."
  }
  description = <<EOD
A list of private IP addresses that will be assigned to BIG-IP instances on their
external interface. The list may be empty, or contain empty strings, to selectively
applies addresses to instances.
EOD
}

variable "external_subnetwork_vip_cidrs" {
  type = list(list(string))
  validation {
    condition     = length(distinct([for cidr in flatten(var.external_subnetwork_vip_cidrs) : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", cidr)) ? "x" : "y"])) < 2
    error_message = "Each external_subnetwork_vip_cidrs value must be a valid IPv4 CIDR."
  }
  description = <<EOD
A list of VIP CIDR lists to assign to BIG-IP instances on their
external interface. E.g. to assign two CIDR blocks as VIPs on the first instance,
and a single IP address as a VIP on the second instance:-

external_subnetwork_vip_cidrs = [
  [
    "10.1.0.0/16",
    "10.2.0.0/24",
  ],
  [
    "192.168.0.1/32",
  ]
]
EOD
}

variable "external_subnetwork_public_ips" {
  type    = list(string)
  default = []
  validation {
    condition     = length(join("", [for ip in var.external_subnetwork_public_ips : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", ip)) ? "x" : ""])) == length(var.external_subnetwork_public_ips)
    error_message = "Each external_subnetwork_public_ips value must be a valid IPv4 address."
  }
  description = <<EOD
An optional list of public IP addresses to assign to BIG-IP instances on their
external interface. The list may be empty, or contain empty strings, to selectively
applies addresses to instances.

Note: these values are only applied if `provision_external_public_ip` is 'true'
and will be ignored if that value is false.
EOD
}

variable "provision_internal_public_ip" {
  type        = bool
  description = <<EOD
If this flag is set to true, a publicly routable IP address WILL be assigned to
the internal interfaces of instances. If set to false, the BIG-IP instances will
NOT have a public IP address assigned to the internal interfaces.
EOD
}

variable "internal_subnetwork_network_ips" {
  type = list(list(string))
  validation {
    condition     = length(distinct([for ip in flatten(var.internal_subnetwork_network_ips) : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", ip)) ? "x" : "y"])) < 2
    error_message = "Each internal_subnetwork_network_ips value must be a valid IPv4 address."
  }
  description = <<EOD
A list of lists of private IP addresses to assign to BIG-IP instances on their
internal interface. The list may be empty, or contain empty strings, to
selectively apply addresses to instances. E.g. to assign addresses to two
internal networks:-

internal_subnetwork_network_ips = [
  # Will be assigned to first instance
  [
    "10.0.0.4", # first internal nic
    "10.0.1.4", # second internal nic
  ],
  # Will be assigned to second instance
  [
    ...
  ],
  ...
]
EOD
}

variable "internal_subnetwork_vip_cidrs" {
  type    = list(list(list(string)))
  default = []
  validation {
    condition     = length(distinct([for cidr in flatten(var.internal_subnetwork_vip_cidrs) : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", cidr)) ? "x" : "y"])) < 2
    error_message = "Each internal_subnetwork_vip_cidrs value must be a valid IPv4 CIDR."
  }
  description = <<EOD
An optional list of CIDR lists to assign to BIG-IP instances as VIPs on their
internal interface. E.g. to assign two CIDR blocks as VIPs on the first
instance, and a single IP address as a VIP on the second instance:-

internal_subnetwork_vip_cidrs = [
  # Will be assigned to first instance
  [
    ["10.1.0.0/16"], # first internal nic
    ["10.2.0.0/24"], # second internal nic
  ],
  # Will be assigned to second instance
  [
    ["192.168.0.1/32"], # first internal nic
  ]
]
EOD
}

variable "internal_subnetwork_public_ips" {
  type    = list(list(string))
  default = []
  validation {
    condition     = length(distinct([for ip in flatten(var.internal_subnetwork_public_ips) : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", ip)) ? "x" : "y"])) < 2
    error_message = "Each internal_subnetwork_public_ips value must be a valid IPv4 address."
  }
  description = <<EOD
An optional list of lists of public IP addresses to assign to BIG-IP instances
on their internal interface. The list may be empty, or contain empty strings, to
selectively applies addresses to instances.

Note: these values are only applied if `provision_internal_public_ip` is 'true'
and will be ignored if that value is false.

E.g. to assign addresses to two internal networks:

internal_subnetwork_network_ips = [
  # Will be assigned to first instance
  [
    "x.x.x.x", # first internal nic
    "y.y.y.y", # second internal nic
  ],
  # Will be assigned to second instance
  [
    ...
  ],
  ...
]
EOD
}

variable "allow_service" {
  type        = map(string)
  default     = {}
  description = <<EOD
A map of 'allowService' values to apply to named DO interfaces. If an specific
value is not found for an interface, the value 'none' shall be applied to internal
interfaces, and default to external.

E.g. to allow default service on internal but none on external interfaces:
allow_service = {
  external = "none"
  internal = "default"
}
EOD
}

variable "additional_configs" {
  type        = list(string)
  default     = []
  description = <<EOD
A list of additional DO configuration snippets JSON to merge with the generated
payloads. Any JSON provided here will be inserted as-is into the "Common" object
after any self IPs, routes, etc. Entries will not be merged or validated.

E.g. to add a new self IP to each generated payload:

additional_configs = [
  "\"extra-self\": {
    \"class\": \"SelfIp\",
    \"address\": \"1.2.3.4/32\",
    ...
  }",
  ...
]
EOD
}

variable "extramb" {
  type    = number
  default = 2048
  validation {
    condition     = var.extramb >= 0 && var.extramb <= 2560 && floor(var.extramb) == var.extramb
    error_message = "The extramb variable must be an integer >= 0 and <= 2560."
  }
  description = <<EOD
The amount of extra RAM (in Mb) to allocate to BIG-IP administrative processes;
must be an integer between 0 and 2560. The default of 2048 is recommended for
BIG-IP instances on GCP; setting too low can cause issues when applying DO or
AS3 payloads.
EOD
}

variable "default_gateway" {
  type    = string
  default = ""
  validation {
    condition     = var.default_gateway == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.default_gateway))
    error_message = "The default_geatway value must be empty or a valid IPv4 address."
  }
  description = <<EOD
Set this to the value to use as the default gateway for BIG-IP instances. This
must be a valid IP address or an empty string. If left blank (default), the
generated Declarative Onboarding JSON will use the gateway associated with nic0
at run-time.
EOD
}
