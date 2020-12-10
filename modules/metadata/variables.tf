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
    "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.16.0/f5-telemetry-1.16.0-4.noarch.rpm",
  ]
  description = <<EOD
An optional list of cloud library URLs that will be downloaded and installed on
the BIG-IP VM during initial boot. The contents of each download will be compared
to the verifyHash file, and failure will cause the boot scripts to fail. Default
list will install F5 Cloud Libraries (w/GCE extension), AS3, Declarative
Onboarding, and Telemetry Streaming extensions.
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
An optional, but recommended, list of AS3 JSON declarations that can be used to
setup the BIG-IP instances. If left empty (default), a no-op AS3 declaration
will be generated for each instance.

The l
EOD
}

variable "do_payloads" {
  type        = list(string)
  description = <<EOD
A list of Declarative Onboarding JSON that will be used to setup the BIG-IP
instance.
EOD
}

variable "do_filter_jq" {
  type        = string
  default     = ""
  description = <<EOD
An optional JQ filter to apply to DO payloads prior to apply. Default is an empty
string.
EOD
}

variable "num_instances" {
  type        = number
  default     = 1
  description = <<EOD
The number of BIG-IP metadata sets to provision. Default value is 1.
EOD
}
