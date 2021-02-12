variable "metadata" {
  type        = map(string)
  default     = {}
  description = <<EOD
An optional map of initial metadata values that will be the base of generated
metadata.
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
