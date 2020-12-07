output "self_links" {
  value       = module.ha.self_links
  description = <<EOD
A list of self-links of the BIG-IP instances.
EOD
}

output "external_addresses" {
  value       = module.ha.external_addresses
  description = <<EOD
A list of the IP addresses and alias CIDRs assigned to instances on the external
NIC.
EOD
}

output "external_vips" {
  value       = module.ha.external_vips
  description = <<EOD
A list of IP CIDRs assigned to the active instance on its external NIC.
EOD
}

output "management_addresses" {
  value       = module.ha.management_addresses
  description = <<EOD
A list of the IP addresses and alias CIDRs assigned to instances on the
management NIC, if present.
EOD
}

output "internal_addresses" {
  value       = module.ha.internal_addresses
  description = <<EOD
A list of the IP addresses and alias CIDRs assigned to instances on the internal
NICs, if present.
EOD
}


output "instance_addresses" {
  value       = module.ha.instance_addresses
  description = <<EOD
A map of instance name to assigned IP addresses and alias CIDRs.
EOD
}

output "external_public_ips" {
  value       = module.ha.external_public_ips
  description = <<EOD
A list of the public IP addresses assigned to instances on the external NIC.
EOD
}

output "management_public_ips" {
  value       = module.ha.management_public_ips
  description = <<EOD
A list of the public IP addresses assigned to instances on the management NIC,
if present.
EOD
}

output "internal_public_ips" {
  value       = module.ha.internal_public_ips
  description = <<EOD
A list of the public IP addresses assigned to instances on the internal NICs,
if present.
EOD
}

output "zone_instances" {
  value       = module.ha.zone_instances
  description = <<EOD
A map of compute zones from var.zones input variable to instance self-links. If
no instances are deployed to a zone, the mapping will be to an empty list.

E.g. if `var.zones = ["us-east1-a", "us-east1-b", "us-east1-c"]` and
`var.num_instances = 2` then the output will be:
{
  us-east1-a = [self-link-instance0]
  us-east1-b = [self-link-instance1]
  us-east1-c = []
}
EOD
}
