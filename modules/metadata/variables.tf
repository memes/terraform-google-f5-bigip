variable "metadata" {
  type        = map(string)
  default     = {}
  description = <<EOD
An optional map of initial metadata values that will be the base of generated
metadata.
EOD
}

variable "enable_os_login" {
  type        = bool
  default     = false
  description = <<EOD
Set to true to enable OS Login on the VMs. Default value is false. If disabled
you must ensure that SSH keys are set explicitly for this instance (see
`ssh_keys` or set in project metadata.
EOD
}

variable "enable_serial_console" {
  type        = bool
  default     = false
  description = <<EOD
Set to true to enable serial port console on the VMs. Default value is false.
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

variable "image" {
  type = string
  validation {
    condition     = can(regex("^(https://www.googleapis.com/compute/v1/)?projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/global/images/[a-z]([a-z0-9-]*[a-z0-9])?", var.image))
    error_message = "The image variable must be a fully-qualified URI."
  }
  description = <<EOD
The self-link URI for a BIG-IP image to use as a base for the VM cluster. This
can be an official F5 image from GCP Marketplace, or a customised image.
EOD
}

variable "ntp_servers" {
  type        = list(string)
  default     = ["169.254.169.254"]
  description = <<EOD
An optional list of NTP servers for BIG-IP instances to use. The default is
["169.254.169.254"] to use GCE metadata server.
EOD
}

variable "timezone" {
  type        = string
  default     = "UTC"
  description = <<EOD
The Olson timezone string from /usr/share/zoneinfo for BIG-IP instances. The
default is 'UTC'. See the TZ column here
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
See `do_payload`.

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

variable "allow_usage_analytics" {
  type        = bool
  default     = true
  description = <<EOD
Allow the BIG-IP VMs to send anonymous statistics to F5 to help us determine how
to improve our solutions (default). If set to false no statistics will be sent.
EOD
}

variable "region" {
  type        = string
  default     = ""
  description = <<EOD
An optional region attribute to include in usage analytics. Default value is an
empty string.
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
  type    = string
  default = "byol"
  validation {
    condition     = contains(list("byol", "payg"), var.license_type)
    error_message = "The license_type variable must be one of 'byol', or 'payg'."
  }
  description = <<EOD
A BIG-IP license type to use with the BIG-IP instance. Must be one of "byol" or
"payg", with "byol" as the default. If set to "payg", the image must be a PAYG
image from F5's official project or the instance will fail to onboard correctly.
EOD
}

variable "install_cloud_libs" {
  type = list(string)
  default = [
    "https://cdn.f5.com/product/cloudsolutions/f5-cloud-libs/v4.23.1/f5-cloud-libs.tar.gz",
    "https://cdn.f5.com/product/cloudsolutions/f5-cloud-libs-gce/v2.7.0/f5-cloud-libs-gce.tar.gz",
    "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.24.0/f5-appsvcs-3.24.0-5.noarch.rpm",
    "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.17.0/f5-declarative-onboarding-1.17.0-3.noarch.rpm",
  ]
  description = <<EOD
An optional list of cloud library URLs that will be downloaded and installed on
the BIG-IP VM during initial boot. The contents of each download will be compared
to the verifyHash file, and failure will cause the boot scripts to fail. Default
list will install F5 Cloud Libraries (w/GCE extension), AS3, and Declarative
Onboarding extensions.
EOD
}

variable "default_gateway" {
  type        = string
  default     = "$EXT_GATEWAY"
  description = <<EOD
Set this to the value to use as the default gateway for BIG-IP instances. This
could be an IP address, a shell command, or environment variable to use at
run-time. Set to blank to delete the default gateway without an explicit
replacement.

Default value is '$EXT_GATEWAY' which will match the run-time upstream gateway
for nic0.

NOTE: this string will be inserted into the boot script as-is.
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
  type        = string
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
An optional, but recommended, list of AS3 JSON declarations that can be used to
setup the BIG-IP instances. If left empty (default), a no-op AS3 declaration
will be generated for each instance.

The l
EOD
}

variable "do_payloads" {
  type        = list(string)
  default     = []
  description = <<EOD
An optional, but recommended, list of Declarative Onboarding JSON that can be used to
setup the BIG-IP instance. If left blank (default), a minimal Declarative
Onboarding will be generated and used.
EOD
}

variable "hostnames" {
  type        = list(string)
  default     = []
  description = <<EOD
An optional list of hostname declarations to set per-instance hostname in
generated DO file. Default is an empty list, which will exclude hostname
from the generated DO file.
EOD
}

variable "dns_servers" {
  type        = list(string)
  default     = ["169.254.169.254"]
  description = <<EOD
An optional list of DNS servers for BIG-IP instances to use. The default is
["169.254.169.254"] to use GCE metadata server.
EOD
}

variable "search_domains" {
  type        = list(string)
  default     = ["google.internal"]
  description = <<EOD
An optional list of DNS search domains for BIG-IP instances to use. The default
is ["google.internal"].
EOD
}

variable "num_instances" {
  type        = number
  default     = 1
  description = <<EOD
The number of BIG-IP metadata sets to provision. Default value is 1.
EOD
}
