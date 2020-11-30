variable "project_id" {
  type        = string
  description = <<EOD
The GCP project identifier where the cluster will be created.
EOD
}

variable "bigip_service_account" {
  type = string
  validation {
    condition     = can(regex("(?:\\.iam|developer)\\.gserviceaccount\\.com$", var.bigip_service_account))
    error_message = "The bigip_service_account variable must be a valid GCP service account email address."
  }
  description = <<EOD
The service account that will be used for the BIG-IP VMs; the firewall rules will
be constructed to use this for source and target filtering.
EOD
}

variable "management_firewall_name" {
  type    = string
  default = "allow-bigip-configsync-mgt"
  validation {
    condition     = can(regex("^[a-z](?:[-a-z0-9]*[a-z0-9]){0,62}$", var.management_firewall_name))
    error_message = "The management_firewall_name variable must be valid RFC1035."
  }
  description = <<EOD
The name to use for Management (control-plane) network firewall rule. Default is
'allow-bigip-configsync-mgt'.
EOD
}

variable "management_network" {
  type = string
  validation {
    condition     = can(regex("^(?:https://www.googleapis.com/compute/v1/projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/global/networks/)?[a-z](?:[-a-z0-9]*[a-z0-9]){0,62}$", var.management_network))
    error_message = "The management_network variable must be a fully-qualified self-link URI, or RFC1035 network name."
  }
  description = <<EOD
The fully-qualified self-link of the subnet that will be used for Management
(control-plane) ConfigSync traffic.
EOD
}

variable "dataplane_firewall_name" {
  type    = string
  default = "allow-bigip-configsync-data-plane"
  validation {
    condition     = can(regex("^[a-z](?:[-a-z0-9]*[a-z0-9]){0,62}$", var.dataplane_firewall_name))
    error_message = "The dataplane_firewall_name variable must be valid RFC1035."
  }
  description = <<EOD
The name to use for data-plane network firewall rule. Default is
'allow-bigip-configsync-data-plane'.
EOD
}

variable "dataplane_network" {
  type = string
  validation {
    condition     = can(regex("^(?:https://www.googleapis.com/compute/v1/projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/global/networks/)?[a-z](?:[-a-z0-9]*[a-z0-9]){0,62}$", var.dataplane_network))
    error_message = "The dataplane_network variable must be a fully-qualified self-link URI, or RFC1035 network name."
  }
  description = <<EOD
The fully-qualified self-link of the subnet that will be used for data-plane
ConfigSync traffic.
EOD
}
