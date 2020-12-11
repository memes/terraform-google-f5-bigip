output "sa" {
  value       = module.sa.emails["bigip"]
  description = <<EOD
The fully-qualified service account email to use with BIG-IP instances.
EOD
}

output "secret_id" {
  value       = module.password.secret_id
  description = <<EOD
The project-local secret id containing the generated BIG-IP admin password.
EOD
}

output "alpha_net" {
  value       = module.alpha.network_self_link
  description = <<EOD
Self-link of the alpha network.
EOD
}

output "alpha_subnet" {
  value       = element(module.alpha.subnets_self_links, 0)
  description = <<EOD
Self-link of the alpha subnet.
EOD
}

output "beta_net" {
  value       = module.beta.network_self_link
  description = <<EOD
Self-link of the beta network.
EOD
}

output "beta_subnet" {
  value       = element(module.beta.subnets_self_links, 0)
  description = <<EOD
Self-link of the beta subnet.
EOD
}

output "gamma_net" {
  value       = module.gamma.network_self_link
  description = <<EOD
Self-link of the gamma network.
EOD
}

output "gamma_subnet" {
  value       = element(module.gamma.subnets_self_links, 0)
  description = <<EOD
Self-link of the gamma subnet.
EOD
}

output "delta_net" {
  value       = module.delta.network_self_link
  description = <<EOD
Self-link of the delta network.
EOD
}

output "delta_subnet" {
  value       = element(module.delta.subnets_self_links, 0)
  description = <<EOD
Self-link of the delta subnet.
EOD
}

output "epsion_net" {
  value       = module.epsilon.network_self_link
  description = <<EOD
Self-link of the epsilon network.
EOD
}

output "epsilon_subnet" {
  value       = element(module.epsilon.subnets_self_links, 0)
  description = <<EOD
Self-link of the epsilon subnet.
EOD
}

output "zeta_net" {
  value       = module.zeta.network_self_link
  description = <<EOD
Self-link of the zeta network.
EOD
}

output "zeta_subnet" {
  value       = element(module.zeta.subnets_self_links, 0)
  description = <<EOD
Self-link of the zeta subnet.
EOD
}

output "eta_net" {
  value       = module.eta.network_self_link
  description = <<EOD
Self-link of the eta network.
EOD
}

output "eta" {
  value       = element(module.eta.subnets_self_links, 0)
  description = <<EOD
Self-link of the eta subnet.
EOD
}

output "theta_net" {
  value       = module.theta.network_self_link
  description = <<EOD
Self-link of the theta network.
EOD
}

output "theta_subnet" {
  value       = element(module.theta.subnets_self_links, 0)
  description = <<EOD
Self-link of the theta subnet.
EOD
}
