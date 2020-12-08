variable "project_id" {
  type        = string
  description = <<EOD
The GCP project identifier where the cluster will be created.
EOD
}


variable "id" {
  type        = string
  default     = ""
  description = <<EOD
An identifier to use for the new role; default is an empty string which will
generate a unique identifier. If a value is provided, it must be unique at the
organization or project level depending on value of target_type respectively.
E.g. multiple projects can all have a 'bigip_cfe' role defined,
but an organization level role must be uniquely named.
EOD
}

variable "members" {
  type        = list(string)
  default     = []
  description = <<EOD
An optional list of accounts that will be assigned the custom role. Default is
an empty list.
EOD
}
