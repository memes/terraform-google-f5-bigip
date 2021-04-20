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
  value       = ""
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
  value       = slice(random_shuffle.zones.result, 0, 1)
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
  value       = var.admin_password_secret_manager_key
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
  value       = []
  description = <<EOD
A list of list of private IP addresses that should be applied to the BIG-IP
instances.
EOD
}

output "public_addresses" {
  value       = []
  description = <<EOD
A list of list of public IP addresses that should be applied to the BIG-IP
instances.
EOD
}

#
# Module under test outputs - these too will be available as 'output_NAME'
#

output "self_links" {
  value       = module.example.self_links
  description = <<EOD
A list of self-links of the BIG-IP instances.
EOD
}
