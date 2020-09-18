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
A list of IP CIDRs asssigned to the active instance on its external NIC.
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
