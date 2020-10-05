variable "project_id" {
  type        = string
  description = <<EOD
The GCP project identifier where the cluster will be created.
EOD
}

variable "region" {
  type        = string
  description = <<EOD
The compute region which will host the BIG-IP VMs.
EOD
}

variable "num_instances" {
  type        = number
  default     = 2
  description = <<EOD
The number of BIG-IP instances to provision in the group. Default value is 2.
EOD
}

variable "group_name" {
  type        = string
  default     = "bigip"
  description = <<EOD
The name to give to the collective and shared resources created by these scripts,
and will be used as the prefix where appropriate. Default value is 'bigip'.
EOD
}

variable "domain_name" {
  type        = string
  default     = ""
  description = <<EOD
An optional domain name to append to generated instance names to fully-qualify
them. If an empty string (default), then the instances will be configured using
DHCP name.
EOD
}

variable "description" {
  type        = string
  default     = ""
  description = <<EOD
An optional description that will be applied to the instances. Default value is
an empty string, which will be replaced by a generated description at run-time.
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

See also `enable_os_login`.
EOD
}

variable "enable_os_login" {
  type        = bool
  default     = false
  description = <<EOD
Set to true to enable OS Login on the VMs. Default value is false as BIG-IP does
not support in OS Login mode currently.
NOTE: this value will override an 'enable-oslogin' key in `metadata` map.
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
    condition     = contains(list("pd-ssd", "pd-standard"), var.disk_type)
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
    condition     = contains(list("PREMIUM", "STANDARD"), var.external_subnetwork_tier)
    error_message = "The external_subnetwork_tier variable must be 'PREMIUM' or 'STANDARD'."
  }
  description = <<EOD
The network tier to set for external subnetwork; must be one of 'PREMIUM'
(default) or 'STANDARD'. This setting only applies if the external interface is
permitted to have a public IP address (see `provision_external_public_ip`)
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
    condition     = contains(list("PREMIUM", "STANDARD"), var.management_subnetwork_tier)
    error_message = "The management_subnetwork_tier variable must be 'PREMIUM' or 'STANDARD'."
  }
  description = <<EOD
The network tier to set for management subnetwork; must be one of 'PREMIUM'
(default) or 'STANDARD'. This setting only applies if the management interface is
permitted to have a public IP address (see `provision_management_public_ip`)
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
    condition     = contains(list("PREMIUM", "STANDARD"), var.internal_subnetwork_tier)
    error_message = "The internal_subnetwork_tier variable must be 'PREMIUM' or 'STANDARD'."
  }
  description = <<EOD
The network tier to set for internal subnetwork; must be one of 'PREMIUM'
(default) or 'STANDARD'. This setting only applies if the internal interface is
permitted to have a public IP address (see `provision_internal_public_ip`)
EOD
}

variable "allow_usage_analytics" {
  type        = bool
  default     = true
  description = <<EOD
Allow the BIG-IP VMs to send anonymous statistics to F5 to help us determine how
to improve our solutions (default). If set to false no statistics will be sent.
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

variable "license_type" {
  type        = string
  default     = "byol"
  description = <<EOD
A BIG-IP license type to use with the BIG-IP instance. Must be one of "byol" or
"payg", with "byol" as the default. If set to "payg", the image must be a PAYG
image from F5's official project or the instance will fail to onboard correctly.
EOD
}

variable "default_gateway" {
  type        = string
  default     = "$EXT_GATEWAY"
  description = <<EOD
Set this to the value to use as the default gateway for BIG-IP instances. This
could be an IP address or environment variable to use at run-time. If left blank,
the onboarding script will use the gateway for nic0.

Default value is '$EXT_GATEWAY' which will match the run-time upstream gateway
for nic0.

NOTE: this string will be inserted into the boot script as-is; it can be an IPv4
address, or a shell variable that is known to exist during network configuration
script execution.
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
Secret Manager using this key.

NOTE: if the secret does not exist, is misidentified, or if the VM cannot read
the secret value associated with this key, then the BIG-IP onboarding will fail
to complete, and onboarding will require manual intervention.
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
AS3 declaration that includes an iRule to satisfy health check requirements; see
`health_check_port` and related variables.
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
for "google.internal".
EOD
}

variable "install_cloud_libs" {
  type = list(string)
  default = [
    "https://cdn.f5.com/product/cloudsolutions/f5-cloud-libs/v4.22.0/f5-cloud-libs.tar.gz",
    "https://cdn.f5.com/product/cloudsolutions/f5-cloud-libs-gce/v2.6.0/f5-cloud-libs-gce.tar.gz",
    "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.22.1/f5-appsvcs-3.22.1-1.noarch.rpm",
    "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.15.0/f5-declarative-onboarding-1.15.0-3.noarch.rpm",
    "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.14.0/f5-telemetry-1.14.0-2.noarch.rpm"
  ]
  description = <<EOD
An optional list of cloud library URLs that will be downloaded and installed on
the BIG-IP VM during initial boot. The contents of each download will be compared
to the verifyHash file, and failure will cause the boot scripts to fail. Default
list will install F5 Cloud Libraries (w/GCE extension), AS3, Declarative
Onboarding, and Telemetry Streaming extensions.
EOD
}

variable "health_check_port" {
  type    = number
  default = 26000
  validation {
    condition     = var.health_check_port > 0 && var.health_check_port < 65536
    error_message = "The health_check_port variable must satisfy 1<= health_check_port <= 65535."
  }
  validation {
    condition     = floor(var.health_check_port) == var.health_check_port
    error_message = "The health_check_port variable must be an integer."
  }
  description = <<EOD
The TCP port to use for health checks; default is 26000. It is expected that a
HTTP 200 response will be returned by BIG-IP when a request targets this port
on the primary IP address assigned to the external network interface.
EOD
}

variable "health_check_name" {
  type        = string
  default     = "bigip-mig"
  description = <<EOD
The name to give to the MIG health check that will determine if BIG-IP instances
should be destroyed. Default is 'bigip-mig'.
EOD
}

variable "health_check_interval_sec" {
  type    = number
  default = 60
  validation {
    condition     = var.health_check_interval_sec > 0
    error_message = "The health_check_interval_sec must be greater than 0."
  }
  description = <<EOD
The interval between health check probes in seconds. Default is 60.
EOD
}

variable "health_check_timeout_sec" {
  type    = number
  default = 10
  validation {
    condition     = var.health_check_timeout_sec > 0
    error_message = "The health_check_timeout_sec must be greater than 0."
  }
  description = <<EOD
The permitted timeout in seconds for health check responses. Default is 10.
EOD
}

variable "health_check_healthy_threshold" {
  type    = number
  default = 2
  validation {
    condition     = var.health_check_healthy_threshold > 0
    error_message = "The health_check_healthy_threshold must be greater than 0."
  }
  validation {
    condition     = floor(var.health_check_healthy_threshold) == var.health_check_healthy_threshold
    error_message = "The health_check_healthy_threshold variable must be an integer."
  }
  description = <<EOD

EOD
}

variable "health_check_unhealthy_threshold" {
  type    = number
  default = 2
  validation {
    condition     = var.health_check_unhealthy_threshold > 0
    error_message = "The health_check_unhealthy_threshold must be greater than 0."
  }
  validation {
    condition     = floor(var.health_check_unhealthy_threshold) == var.health_check_unhealthy_threshold
    error_message = "The health_check_unhealthy_threshold variable must be an integer."
  }
  description = <<EOD

EOD
}

variable "health_check_http_host" {
  type        = string
  default     = ""
  description = <<EOD

EOD
}

variable "health_check_http_path" {
  type        = string
  default     = "/"
  description = <<EOD

EOD
}

variable "health_check_http_response_text" {
  type        = string
  default     = ""
  description = <<EOD

EOD
}

variable "distribution_policy_zones" {
  type        = list(string)
  default     = null
  description = <<EOD

EOD
}

variable "health_check_firewall_name" {
  type    = string
  default = "allow-mig-hc-bigip-ext"
  validation {
    condition     = can(regex("^[a-z](?:[-a-z0-9]*[a-z0-9]){0,62}$", var.health_check_firewall_name))
    error_message = "The health_check_firewall_name variable must be valid RFC1035."
  }
  description = <<EOD
The name to use for GCP health check firewall rule that will be applied to the
external network. Default is 'allow-mig-hc-bigip-ext'.
EOD
}
