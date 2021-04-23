variable "project_id" {
  type        = string
  description = <<EOD
The GCP project identifier where the cluster will be created.
EOD
}

variable "zones" {
  type        = list(string)
  description = <<EOD
The compute zones which will host the BIG-IP VMs.
EOD
}

variable "num_instances" {
  type        = number
  default     = 1
  description = <<EOD
The number of standalone BIG-IP instances to provision. Default value is 1.
EOD
}

variable "instance_name_template" {
  type    = string
  default = "bigip-%d"
  validation {
    condition     = can(regex("%[0-9]*(?:\\.[0-9]+)?[bdoOxX]", var.instance_name_template))
    error_message = "The instance_name_template variable must include a valid integer placeholder field. I.e. '%d', '%x', etc."
  }
  description = <<EOD
A format string that will be used when naming instance, that should include a
format token for including integer ordinal numbers as defined in Go `fmt` package,
including support for zero-padding etc. Default value is 'bigip-%d' which will
generate names of 'bigip-0', 'bigip-1', through 'bigip-N', where N is the number
of instances - 1.

Examples:
instance_name_template = "bigip-%03d" will create instances named 'bigip-000',
'bigip-001', etc.
instance_name_template = "prod-ha-%x" will create instances using lower-case hex
, such as 'prod-ha-0' ... 'prod-ha-1f'.

See `instance_ordinal_offset` variable to change the lower bounds of the numbering
scheme.
EOD
}

variable "instance_ordinal_offset" {
  type    = number
  default = 0
  validation {
    condition     = var.instance_ordinal_offset >= 0 && floor(var.instance_ordinal_offset) == var.instance_ordinal_offset
    error_message = "The instance_ordinal_offset variable must be an integer >= 0."
  }
  description = <<EOD
An offset to apply to each instance ordinal when naming; use to change zero-based
instance ordinal to a different number when setting instance names and hostnames.
Default value is '0'.

E.g. to change 0-based instance names ('bigip-0', 'bigip-1', etc.) to 1-based
instance names ('bigip-1', 'bigip-2', etc.) use
instance_ordinal_offset = 1

See `instance_name_template` for more examples.
EOD
}

variable "domain_name" {
  type        = string
  default     = ""
  description = <<EOD
An optional domain name to append to generated instance names to fully-qualify
them. If an empty string (default), then the instances will be qualified as-per
Google Cloud internal naming conventions ".ZONE.c.PROJECT_ID.internal".
EOD
}

variable "metadata" {
  type        = map(string)
  default     = {}
  description = <<EOD
An optional map of metadata values that will be applied to the instances.
EOD
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = <<EOD
An optional map of *labels* to add to the instance template.
EOD
}

variable "tags" {
  type        = list(string)
  default     = []
  description = <<EOD
An optional list of *network tags* to add to the instance template.
EOD
}

variable "min_cpu_platform" {
  type        = string
  default     = "Intel Skylake"
  description = <<EOD
An optional constraint used when scheduling the BIG-IP VMs; this value prevents
the VMs from being scheduled on hardware that doesn't meet the minimum CPU
micro-architecture. Default value is 'Intel Skylake'.
EOD
}

variable "machine_type" {
  type        = string
  default     = "n1-standard-4"
  description = <<EOD
The machine type to use for BIG-IP VMs; this may be a standard GCE machine type,
or a customised VM ('custom-VCPUS-MEM_IN_MB'). Default value is 'n1-standard-4'.
*Note:* machine_type is highly-correlated with network bandwidth and performance;
an N2 or N2D machine type will give better performance but has limited availability.
EOD
}

variable "service_account" {
  type = string
  validation {
    condition     = can(regex("(?:\\.iam|developer)\\.gserviceaccount\\.com$", var.service_account))
    error_message = "The service_account variable must be a valid GCP service account email address."
  }
  description = <<EOD
The service account that will be used for the BIG-IP VMs.
EOD
}

variable "automatic_restart" {
  type        = bool
  default     = true
  description = <<EOD
Determines if the BIG-IP VMs should be automatically restarted if terminated by
GCE. Defaults to true to match expected GCE behaviour.
EOD
}

variable "preemptible" {
  type        = string
  default     = false
  description = <<EOD
If set to true, the BIG-IP instances will be deployed on preemptible VMs, which
could be terminated at any time, and have a maximum lifetime of 24 hours. Default
value is false.
EOD
}

variable "ssh_keys" {
  type        = string
  default     = ""
  description = <<EOD
An optional set of SSH public keys, concatenated into a single string. The keys
will be added to instance metadata. Default is an empty string.
EOD
}

variable "enable_serial_console" {
  type        = bool
  default     = false
  description = <<EOD
Set to true to enable serial port console on the VMs. Default value is false.
EOD
}

variable "image" {
  type = string
  validation {
    condition     = can(regex("^(?:https://www.googleapis.com/compute/v1/)?projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/global/images/[a-z]([a-z0-9-]*[a-z0-9])?", var.image))
    error_message = "The image variable must be a fully-qualified URI."
  }
  description = <<EOD
The self-link URI for a BIG-IP image to use as a base for the VM cluster. This
can be an official F5 image from GCP Marketplace, or a customised image.
EOD
}

variable "delete_disk_on_destroy" {
  type        = bool
  default     = true
  description = <<EOD
Set this flag to false if you want the boot disk associated with the launched VMs
to survive when instances are destroyed. The default value of true will ensure the
boot disk is destroyed when the instance is destroyed.
EOD
}

variable "disk_type" {
  type    = string
  default = "pd-ssd"
  validation {
    condition     = contains(["pd-ssd", "pd-standard"], var.disk_type)
    error_message = "The disk_type variable must be 'pd-ssd' or 'pd-standard'."
  }
  description = <<EOD
The boot disk type to use with instances; can be 'pd-ssd' (default), or
'pd-standard'.
*Note:* Choosing 'pd-standard' will reduce operating cost, but at the expense of
network performance.
EOD
}

variable "disk_size_gb" {
  type        = number
  default     = null
  description = <<EOD
Use this flag to set the boot volume size in GB. If left at the default value
the boot disk will have the same size as specified in 'bigip_image'.
EOD
}

variable "external_subnetwork" {
  type = string
  validation {
    condition     = can(regex("^https://www.googleapis.com/compute/v1/projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/regions/[a-z][a-z-]+[0-9]/subnetworks/[a-z]([a-z0-9-]*[a-z0-9])?$", var.external_subnetwork))
    error_message = "The external_subnetwork variable must be a fully-qualified self-link URI."
  }
  description = <<EOD
The fully-qualified self-link of the subnet that will be used for external ingress
(2+ NIC deployment), or for all traffic in a 1NIC deployment.
EOD
}

variable "provision_external_public_ip" {
  type        = bool
  default     = true
  description = <<EOD
If this flag is set to true (default), a publicly routable IP address WILL be
assigned to the external interface of instances. If set to false, the BIG-IP
instances will NOT have a public IP address assigned to the external interface.
EOD
}

variable "external_subnetwork_tier" {
  type    = string
  default = "PREMIUM"
  validation {
    condition     = contains(["PREMIUM", "STANDARD"], var.external_subnetwork_tier)
    error_message = "The external_subnetwork_tier variable must be 'PREMIUM' or 'STANDARD'."
  }
  description = <<EOD
The network tier to set for external subnetwork; must be one of 'PREMIUM'
(default) or 'STANDARD'. This setting only applies if the external interface is
permitted to have a public IP address (see `provision_external_public_ip`)
EOD
}

variable "external_subnetwork_network_ips" {
  type    = list(string)
  default = []
  validation {
    condition     = length(join("", [for ip in var.external_subnetwork_network_ips : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", ip)) ? "x" : ""])) == length(var.external_subnetwork_network_ips)
    error_message = "Each external_subnetwork_network_ips value must be a valid IPv4 address."
  }
  description = <<EOD
An optional list of private IP addresses to assign to BIG-IP instances on their
externa interface. The list may be empty, or contain empty strings, to selectively
applies addresses to instances.
EOD
}

variable "external_subnetwork_vip_cidrs" {
  type    = list(list(string))
  default = []
  validation {
    condition     = length(distinct([for cidr in flatten(var.external_subnetwork_vip_cidrs) : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", cidr)) ? "x" : "y"])) < 2
    error_message = "Each external_subnetwork_vip_cidrs value must be a valid IPv4 CIDR."
  }
  description = <<EOD
An optional list of VIP CIDR lists to assign to BIG-IP instances on their
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

variable "external_subnetwork_vip_cidrs_named_range" {
  type        = string
  default     = ""
  description = <<EOD
An optional named range to use when assigning CIDRs to BIG-IP instances as VIPs
on their external interface. E.g. to assign CIDRs from
secondary range 'dmz-bigip':-

external_subnetwork_vip_cidrs_named_range = "dmz-bigip"
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

variable "management_subnetwork" {
  type    = string
  default = null
  validation {
    condition     = var.management_subnetwork == null || var.management_subnetwork == "" || can(regex("^https://www.googleapis.com/compute/v1/projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/regions/[a-z][a-z-]+[0-9]/subnetworks/[a-z]([a-z0-9-]*[a-z0-9])?$", var.management_subnetwork))
    error_message = "The management_subnetwork variable must be a fully-qualified self-link URI."
  }
  description = <<EOD
An optional fully-qualified self-link of the subnet that will be used for
management access (2+ NIC deployment).
EOD
}

variable "provision_management_public_ip" {
  type        = bool
  default     = false
  description = <<EOD
If this flag is set to true, a publicly routable IP address WILL be assigned to
the management interface of instances. If set to false (default), the BIG-IP
instances will NOT have a public IP address assigned to the management interface.
EOD
}

variable "management_subnetwork_tier" {
  type    = string
  default = "PREMIUM"
  validation {
    condition     = contains(["PREMIUM", "STANDARD"], var.management_subnetwork_tier)
    error_message = "The management_subnetwork_tier variable must be 'PREMIUM' or 'STANDARD'."
  }
  description = <<EOD
The network tier to set for management subnetwork; must be one of 'PREMIUM'
(default) or 'STANDARD'. This setting only applies if the management interface is
permitted to have a public IP address (see `provision_management_public_ip`)
EOD
}

variable "management_subnetwork_network_ips" {
  type    = list(string)
  default = []
  validation {
    condition     = length(join("", [for ip in var.management_subnetwork_network_ips : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", ip)) ? "x" : ""])) == length(var.management_subnetwork_network_ips)
    error_message = "Each management_subnetwork_network_ips value must be a valid IPv4 address."
  }
  description = <<EOD
An optional list of private IP addresses to assign to BIG-IP instances on their
management interface. The list may be empty, or contain empty strings, to
selectively applies addresses to instances.
EOD
}

variable "management_subnetwork_vip_cidrs" {
  type    = list(list(string))
  default = []
  validation {
    condition     = length(distinct([for cidr in flatten(var.management_subnetwork_vip_cidrs) : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", cidr)) ? "x" : "y"])) < 2
    error_message = "Each management_subnetwork_vip_cidrs value must be a valid IPv4 CIDR."
  }
  description = <<EOD
An optional list of CIDR lists to assign to BIG-IP instances as VIPs on their
management interface. E.g. to assign two CIDR blocks as VIPs on the first
instance, and a single IP address as an alias on the second instance:-

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

variable "management_subnetwork_vip_cidrs_named_range" {
  type        = string
  default     = ""
  description = <<EOD
An optional named range to use when assigning CIDRs to BIG-IP instances as VIPs
on their management interface. E.g. to assign CIDRs from
secondary range 'management-bigip':-

management_subnetwork_vip_cidrs_named_range = "management-bigip"
EOD
}

variable "management_subnetwork_public_ips" {
  type    = list(string)
  default = []
  validation {
    condition     = length(join("", [for ip in var.management_subnetwork_public_ips : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", ip)) ? "x" : ""])) == length(var.management_subnetwork_public_ips)
    error_message = "Each management_subnetwork_public_ips value must be a valid IPv4 address."
  }
  description = <<EOD
An optional list of public IP addresses to assign to BIG-IP instances on their
management interface. The list may be empty, or contain empty strings, to
selectively applies addresses to instances.

Note: these values are only applied if `provision_management_public_ip` is 'true'
and will be ignored if that value is false.
EOD
}

variable "internal_subnetworks" {
  type    = list(string)
  default = []
  validation {
    condition     = length(var.internal_subnetworks) < 7
    error_message = "A maximum of 6 internal subnetworks can be added to a VM."
  }
  validation {
    condition     = length(join("", [for url in var.internal_subnetworks : can(regex("^https://www.googleapis.com/compute/v1/projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/regions/[a-z][a-z-]+[0-9]/subnetworks/[a-z]([a-z0-9-]*[a-z0-9])?$", url)) ? "x" : ""])) == length(var.internal_subnetworks)
    error_message = "Each internal_subnetworks value must be a fully-qualified self-link URI."
  }
  description = <<EOD
An optional list of fully-qualified subnet self-links that will be assigned as
internal traffic on NICs eth[2-8].
EOD
}

variable "provision_internal_public_ip" {
  type        = bool
  default     = false
  description = <<EOD
If this flag is set to true, a publicly routable IP address WILL be assigned to
the internal interfaces of instances. If set to false (default), the BIG-IP
instances will NOT have a public IP address assigned to the internal interfaces.
EOD
}

variable "internal_subnetwork_tier" {
  type    = string
  default = "PREMIUM"
  validation {
    condition     = contains(["PREMIUM", "STANDARD"], var.internal_subnetwork_tier)
    error_message = "The internal_subnetwork_tier variable must be 'PREMIUM' or 'STANDARD'."
  }
  description = <<EOD
The network tier to set for internal subnetwork; must be one of 'PREMIUM'
(default) or 'STANDARD'. This setting only applies if the internal interface is
permitted to have a public IP address (see `provision_internal_public_ip`)
EOD
}

variable "internal_subnetwork_network_ips" {
  type    = list(list(string))
  default = []
  validation {
    condition     = length(distinct([for ip in flatten(var.internal_subnetwork_network_ips) : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", ip)) ? "x" : "y"])) < 2
    error_message = "Each internal_subnetwork_network_ips value must be a valid IPv4 address."
  }
  description = <<EOD
An optional list of lists of private IP addresses to assign to BIG-IP instances
on their internal interface. The list may be empty, or contain empty strings, to
selectively applies addresses to instances. E.g. to assign addresses to two
internal networks:

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

variable "internal_subnetwork_vip_cidrs_named_ranges" {
  type        = list(string)
  default     = []
  description = <<EOD
An optional named range to use when assigning CIDRs to BIG-IP instances as VIPs
on their internal interfaces. E.g. to assign CIDRs from
secondary range 'internal-bigip' on first internal interface:-

internal_subnetwork_vip_cidrs_named_ranges = [
  "internal-bigip",
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

variable "allow_phone_home" {
  type        = bool
  default     = true
  description = <<EOD
Allow the BIG-IP VMs to send high-level device use information to help F5
optimize development resources. If set to false the information is not sent.
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

variable "use_cloud_init" {
  type        = bool
  default     = false
  description = <<EOD
If this value is set to true, cloud-init will be used as the initial
configuration approach; false (default) will fall-back to a standard shell
script for boot-time configuration.

Note: the BIG-IP version must support Cloud Init on GCP for this to function
correctly. E.g. v15.1+.
EOD
}

variable "admin_password_secret_manager_key" {
  type = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,255}$", var.admin_password_secret_manager_key))
    error_message = "The admin_password_secret_manager_key must be valid."
  }
  description = <<EOD
The Secret Manager key for BIG-IP admin password; during initialisation, the
BIG-IP admin account's password will be changed to the value retrieved from GCP
Secret Manager (or other implementor - see `secret_implementor`) using this key.

NOTE: if the secret does not exist, is misidentified, or if the VM cannot read
the secret value associated with this key, then the BIG-IP onboarding will fail
to complete, and onboarding will require manual intervention.
EOD
}

variable "secret_implementor" {
  type    = string
  default = ""
  validation {
    condition     = var.secret_implementor == "" || contains(["google_secret_manager", "metadata"], var.secret_implementor)
    error_message = "The secret_implementor variable must be empty or a supported secret implementor."
  }
  description = <<EOD
The secret retrieval implementor to use; default value is an empty string.
Must be an empty string, 'google_secret_manager', or 'metadata'. Future
enhancements will add other implementors.
EOD
}

variable "custom_script" {
  type        = string
  default     = ""
  description = <<EOD
An optional, custom shell script that will be executed during BIG-IP
initialisation, after BIG-IP networking is auto-configured, admin password is set from Secret
Manager (if possible), etc. Declarative Onboarding offers a better approach,
where suitable (see `do_payload`).

NOTE: this value should contain the script contents, not a file path.
EOD
}

variable "as3_payloads" {
  type        = list(string)
  default     = []
  description = <<EOD
An optional, but recommended, list of AS3 JSON files that can be used to setup
the BIG-IP instances. If left empty (default), the module will use a simple
no-op AS3 declaration.
EOD
}

variable "do_payloads" {
  type        = list(string)
  default     = []
  description = <<EOD
The Declarative Onboarding contents to apply to the instances. Required. This
module has migrated to use of Declarative Onboarding for module activation,
licensing, NTP, DNS, and other basic configurations. Sample payloads are in the
examples folder.

Note: if left empty, the module will use a simple JSON that sets NTP and DNS,
and enables LTM.
EOD
}

variable "ntp_servers" {
  type        = list(string)
  default     = ["169.254.169.254"]
  description = <<EOD
An optional list of NTP servers for BIG-IP instances to use if custom DO files
are not provided. The default is ["169.254.169.254"] to use GCE metadata server.
EOD
}

variable "timezone" {
  type        = string
  default     = "UTC"
  description = <<EOD
The Olson timezone string from /usr/share/zoneinfo for BIG-IP instances if custom
DO files are not provided. The default is 'UTC'. See the TZ column here
(https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for legal values.
For example, 'US/Eastern'.
EOD
}

variable "modules" {
  type = map(string)
  default = {
    ltm = "nominal"
  }
  description = <<EOD
A map of BIG-IP module = provisioning-level pairs to enable, where the module
name is key, and the provisioning-level is the value. This value is used with the
default Declaration Onboarding template; a better option for full control is to
explicitly declare the modules to be provisioned as part of a custom JSON file.
See `do_payloads`.

E.g. the default is
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

variable "dns_servers" {
  type        = list(string)
  default     = ["169.254.169.254"]
  description = <<EOD
An optional list of DNS servers for BIG-IP instances to use if custom DO payloads
are not provided. The default is ["169.254.169.254"] to use GCE metadata server.
EOD
}

variable "search_domains" {
  type        = list(string)
  default     = []
  description = <<EOD
An optional list of DNS search domains for BIG-IP instances to use if custom DO
payloads are not provided. If left empty (default), search domains will be added
for "google.internal" and the zone/project specific domain assigned to instances.
EOD
}

variable "install_cloud_libs" {
  type = list(string)
  default = [
    "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.25.0/f5-appsvcs-3.25.0-3.noarch.rpm",
    "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.18.0/f5-declarative-onboarding-1.18.0-4.noarch.rpm",
    "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.17.0/f5-telemetry-1.17.0-4.noarch.rpm",
  ]
  description = <<EOD
An optional list of cloud library URLs that will be downloaded and installed on
the BIG-IP VM during initial boot. The contents of each download will be compared
to the verifyHash file, and failure will cause the boot scripts to fail. Default
list will install F5 Cloud Libraries (w/GCE extension), AS3, Declarative
Onboarding, and Telemetry Streaming extensions.
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
BIG-IP instances on GCP; setting too low can cause issues when applying large DO
or AS3 payloads.
EOD
}
