#
# Fixture outputs - these are made available to inspec profiles as 'output_NAME'
#

output "project_id" {
  value       = var.project_id
  description = <<EOD
The project identifier being used for testing.
EOD
}

output "prefix" {
  value       = var.prefix
  description = <<EOD
The prefix prepended to generated resource names for this test.
EOD
}

output "region" {
  value       = var.region
  description = <<EOD
The compute region that will be used for BIG-IP resources.
EOD
}

output "zones" {
  value       = random_shuffle.zones.result
  description = <<EOD
The compute zones that will be used for BIG-IP instances.
EOD
}

output "service_account" {
  value       = var.service_account
  description = <<EOD
The service account to use with the BIG-IP instances.
EOD
}

output "admin_password_secret_manager_key" {
  # allow override of admin_password_secret_manager_key from kitchen.yml
  value       = coalesce(var.override_admin_password_secret_manager_key, var.admin_password_secret_manager_key)
  description = <<EOD
The Secret Manager key for BIG-IP admin password.
EOD
}

output "alpha_net" {
  value       = var.alpha_net
  description = <<EOD
The self-link of alpha network.
EOD
}

output "alpha_subnet" {
  value       = var.alpha_subnet
  description = <<EOD
The self-link of alpha subnet.
EOD
}

output "beta_net" {
  value       = var.beta_net
  description = <<EOD
The self-link of beta network.
EOD
}

output "beta_subnet" {
  value       = var.beta_subnet
  description = <<EOD
The self-link of beta subnet.
EOD
}

output "gamma_net" {
  value       = var.gamma_net
  description = <<EOD
The self-link of gamma network.
EOD
}

output "gamma_subnet" {
  value       = var.gamma_subnet
  description = <<EOD
The self-link of gamma subnet.
EOD
}

output "delta_net" {
  value       = var.delta_net
  description = <<EOD
The self-link of delta network.
EOD
}

output "delta_subnet" {
  value       = var.delta_subnet
  description = <<EOD
The self-link of delta subnet.
EOD
}

output "epsilon_net" {
  value       = var.epsilon_net
  description = <<EOD
The self-link of epsilon network.
EOD
}

output "epsilon_subnet" {
  value       = var.epsilon_subnet
  description = <<EOD
The self-link of epsilon subnet.
EOD
}

output "zeta_net" {
  value       = var.zeta_net
  description = <<EOD
The self-link of zeta network.
EOD
}

output "zeta_subnet" {
  value       = var.zeta_subnet
  description = <<EOD
The self-link of zeta subnet.
EOD
}

output "eta_net" {
  value       = var.eta_net
  description = <<EOD
The self-link of eta network.
EOD
}

output "eta_subnet" {
  value       = var.eta_subnet
  description = <<EOD
The self-link of eta subnet.
EOD
}

output "theta_net" {
  value       = var.theta_net
  description = <<EOD
The self-link of theta network.
EOD
}

output "theta_subnet" {
  value       = var.theta_subnet
  description = <<EOD
The self-link of theta subnet.
EOD
}

output "private_addresses" {
  value       = local.private_ips
  description = <<EOD
A list of list of private IP addresses that should be applied to the BIG-IP
instances.
EOD
}

output "public_addresses" {
  value       = local.public_ips
  description = <<EOD
A list of list of public IP addresses that should be applied to the BIG-IP
instances.
EOD
}

#
# Module under test outputs - these too will be available as 'output_NAME'
#

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
A list of IP CIDRs assigned to instances on the external NIC, which usually
corresponds to the VIPs defined on each instance.
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
EOD
}

output "management_fw_self_link" {
  value       = module.configsync_fw.management_self_link
  description = <<EOD
The self-link for the ConfigSync firewall rule added to management network.
EOD
}

output "dataplane_fw_self_link" {
  value       = module.configsync_fw.dataplane_self_link
  description = <<EOD
The self-link for the ConfigSync firewall rule added to data-plane network.
EOD
}
