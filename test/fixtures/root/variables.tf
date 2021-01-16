#
# These are suite-specific variables that drive behaviour and are not always a
# 1:1 mapping with the inputs of the root module.
#

variable "num_nics" {
  type        = number
  description = <<EOD
The number of network interfaces to provision in BIG-IP test instances.
EOD
}

variable "reserve_addresses" {
  type        = bool
  description = <<EOD
Toggle the use of address reservation in scenario; if true then a set of addresses
will be reserved on networks and supplied to BIG-IP module. This will include
public reservations if `provision_[TYPE]_public_ip` is set to true.
EOD
}

variable "override_admin_password_secret_manager_key" {
  type        = string
  default     = ""
  description = <<EOD
Override the Secret Manager key for BIG-IP admin password.
EOD
}

#
# These inputs will be set from test/setup/harness.tfvars
#

variable "tf_sa_email" {
  type        = string
  default     = ""
  description = <<EOD
The fully-qualified email address of the Terraform service account to use for
resource creation via account impersonation. If left blank, the default, then
the invoker's account will be used.

E.g. if you have permissions to impersonate:

tf_sa_email = "terraform@PROJECT_ID.iam.gserviceaccount.com"
EOD
}

variable "tf_sa_token_lifetime_secs" {
  type        = number
  default     = 600
  description = <<EOD
The expiration duration for the service account token, in seconds. This value
should be high enough to prevent token timeout issues during resource creation,
but short enough that the token is useless replayed later. Default value is 600
(10 mins).
EOD
}

variable "project_id" {
  type        = string
  description = <<EOD
The GCP project identifier where the cluster will be created.
EOD
}

variable "prefix" {
  type        = string
  description = <<EOD
The prefix to apply to GCP resources created in this test run.
EOD
}

variable "region" {
  type        = string
  description = <<EOD
The compute region which will host the BIG-IP VMs.
EOD
}

variable "service_account" {
  type        = string
  description = <<EOD
The service account to use with BIG-IP.
EOD
}

variable "admin_password_secret_manager_key" {
  type        = string
  description = <<EOD
The Secret Manager key for BIG-IP admin password.
EOD
}

variable "alpha_net" {
  type        = string
  description = <<EOD
Self-link of alpha network.
EOD
}

variable "alpha_subnet" {
  type        = string
  description = <<EOD
Self-link of alpha subnet.
EOD
}

variable "beta_net" {
  type        = string
  description = <<EOD
Self-link of beta network.
EOD
}

variable "beta_subnet" {
  type        = string
  description = <<EOD
Self-link of beta subnet.
EOD
}

variable "gamma_net" {
  type        = string
  description = <<EOD
Self-link of gamma network.
EOD
}

variable "gamma_subnet" {
  type        = string
  description = <<EOD
Self-link of gamma subnet.
EOD
}

variable "delta_net" {
  type        = string
  description = <<EOD
Self-link of delta network.
EOD
}

variable "delta_subnet" {
  type        = string
  description = <<EOD
Self-link of delta subnet.
EOD
}

variable "epsilon_net" {
  type        = string
  description = <<EOD
Self-link of epsilon network.
EOD
}

variable "epsilon_subnet" {
  type        = string
  description = <<EOD
Self-link of epsilon subnet.
EOD
}

variable "zeta_net" {
  type        = string
  description = <<EOD
Self-link of zeta network.
EOD
}

variable "zeta_subnet" {
  type        = string
  description = <<EOD
Self-link of zeta subnet.
EOD
}

variable "eta_net" {
  type        = string
  description = <<EOD
Self-link of eta network.
EOD
}

variable "eta_subnet" {
  type        = string
  description = <<EOD
Self-link of eta subnet.
EOD
}

variable "theta_net" {
  type        = string
  description = <<EOD
Self-link of theta network.
EOD
}

variable "theta_subnet" {
  type        = string
  description = <<EOD
Self-link of theta subnet.
EOD
}

#
# The remaining inputs map 1:1 with the those of the root module; where the root
# input has a default these will too of the same value. Objective is to make
# the harness behave like the root module unless overridden.
#

variable "num_instances" {
  type        = number
  default     = 1
  description = <<EOD
The number of BIG-IP instances to provision.
EOD
}


variable "instance_name_template" {
  type        = string
  default     = "bigip-%d"
  description = <<EOD
A format string that will be used when naming instances.
EOD
}

variable "instance_ordinal_offset" {
  type        = number
  default     = 0
  description = <<EOD
An offset to apply to each instance ordinal when naming.
EOD
}

variable "domain_name" {
  type        = string
  default     = ""
  description = <<EOD
An optional domain name to append to generated instance names to fully-qualify
them.
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
micro-architecture.
EOD
}

variable "machine_type" {
  type        = string
  default     = "n1-standard-4"
  description = <<EOD
The machine type to use for BIG-IP VMs; this may be a standard GCE machine type,
or a customised VM ('custom-VCPUS-MEM_IN_MB').
EOD
}

variable "automatic_restart" {
  type        = bool
  default     = true
  description = <<EOD
Determines if the BIG-IP VMs should be automatically restarted if terminated by
GCE.
EOD
}

variable "preemptible" {
  type        = string
  default     = false
  description = <<EOD
If set to true, the BIG-IP instances will be deployed on preemptible VMs, which
could be terminated at any time, and have a maximum lifetime of 24 hours.
EOD
}

variable "ssh_keys" {
  type        = string
  default     = ""
  description = <<EOD
An optional set of SSH public keys, concatenated into a single string.
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
  type        = string
  default     = "projects/f5-7626-networks-public/global/images/f5-bigip-15-1-2-0-0-9-payg-good-25mbps-201110225418"
  description = <<EOD
The self-link URI for a BIG-IP image to use as a base for the VM cluster.
EOD
}

variable "delete_disk_on_destroy" {
  type        = bool
  default     = true
  description = <<EOD
Set this flag to false if you want the boot disk associated with the launched VMs
to survive when instances are destroyed.
EOD
}

variable "disk_type" {
  type        = string
  default     = "pd-ssd"
  description = <<EOD
The boot disk type to use with instances; can be 'pd-ssd' (default), or
'pd-standard'.
EOD
}

variable "disk_size_gb" {
  type        = number
  default     = null
  description = <<EOD
Use this flag to set the boot volume size in GB.
EOD
}

variable "provision_external_public_ip" {
  type        = bool
  default     = true
  description = <<EOD
If this flag is set to true (default), a publicly routable IP address WILL be
assigned to the external interface of instances.
EOD
}

variable "external_subnetwork_tier" {
  type        = string
  default     = "PREMIUM"
  description = <<EOD
The network tier to set for external subnetwork; must be one of 'PREMIUM'
(default) or 'STANDARD'.
EOD
}

variable "provision_management_public_ip" {
  type        = bool
  default     = false
  description = <<EOD
If this flag is set to true, a publicly routable IP address WILL be assigned to
the management interface of instances.
EOD
}

variable "management_subnetwork_tier" {
  type        = string
  default     = "PREMIUM"
  description = <<EOD
The network tier to set for management subnetwork; must be one of 'PREMIUM'
(default) or 'STANDARD'.
EOD
}

variable "provision_internal_public_ip" {
  type        = bool
  default     = false
  description = <<EOD
If this flag is set to true, a publicly routable IP address WILL be assigned to
the internal interfaces of instances.
EOD
}

variable "internal_subnetwork_tier" {
  type        = string
  default     = "PREMIUM"
  description = <<EOD
The network tier to set for internal subnetwork; must be one of 'PREMIUM'
(default) or 'STANDARD'.
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
  type        = string
  default     = ""
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
configuration approach.
EOD
}

variable "secret_implementor" {
  type        = string
  default     = ""
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

variable "extramb" {
  type        = number
  default     = 2048
  description = <<EOD
The amount of extra RAM (in Mb) to allocate to BIG-IP administrative processes;
must be an integer between 0 and 2560. The default of 2048 is recommended for
BIG-IP instances on GCP; setting too low can cause issues when applying DO or
AS3 payloads.
EOD
}
