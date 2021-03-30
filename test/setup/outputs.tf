output "tf_sa_email" {
  value       = var.tf_sa_email
  description = <<EOD
The service account to use with account impersonation when creating resources or
invoking gcloud commands. May be empty.
EOD
}

output "project_id" {
  value       = var.project_id
  description = <<EOD
The GCP project identifier to use for testing.
EOD
}

output "prefix" {
  value       = random_id.prefix.hex
  description = <<EOD
The prefix that will be applied to generated resources in this test run.
EOD
}

output "service_account" {
  value       = module.bigip_sa.email
  description = <<EOD
The fully-qualified service account email to use with BIG-IP instances.
EOD
}

output "admin_password_secret_manager_key" {
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

output "alpha_subnets" {
  value       = { for k, v in module.alpha.subnets : v.region => v.self_link }
  description = <<EOD
Map of region:subnet self-link for alpha subnets.
EOD
}

output "beta_net" {
  value       = module.beta.network_self_link
  description = <<EOD
Self-link of the beta network.
EOD
}

output "beta_subnets" {
  value       = { for k, v in module.beta.subnets : v.region => v.self_link }
  description = <<EOD
Map of region:subnet self-link for beta subnets.
EOD
}

output "gamma_net" {
  value       = module.gamma.network_self_link
  description = <<EOD
Self-link of the gamma network.
EOD
}

output "gamma_subnets" {
  value       = { for k, v in module.gamma.subnets : v.region => v.self_link }
  description = <<EOD
Map of region:subnet self-link for gamma subnets.
EOD
}

output "delta_net" {
  value       = module.delta.network_self_link
  description = <<EOD
Self-link of the delta network.
EOD
}

output "delta_subnets" {
  value       = { for k, v in module.delta.subnets : v.region => v.self_link }
  description = <<EOD
Map of region:subnet self-link for delta subnets.
EOD
}

output "epsilon_net" {
  value       = module.epsilon.network_self_link
  description = <<EOD
Self-link of the epsilon network.
EOD
}

output "epsilon_subnets" {
  value       = { for k, v in module.epsilon.subnets : v.region => v.self_link }
  description = <<EOD
Map of region:subnet self-link for epsilon subnets.
EOD
}

output "zeta_net" {
  value       = module.zeta.network_self_link
  description = <<EOD
Self-link of the zeta network.
EOD
}

output "zeta_subnets" {
  value       = { for k, v in module.zeta.subnets : v.region => v.self_link }
  description = <<EOD
Map of region:subnet self-link for zeta subnets.
EOD
}

output "eta_net" {
  value       = module.eta.network_self_link
  description = <<EOD
Self-link of the eta network.
EOD
}

output "eta_subnets" {
  value       = { for k, v in module.eta.subnets : v.region => v.self_link }
  description = <<EOD
Map of region:subnet self-link for eta subnets.
EOD
}

output "theta_net" {
  value       = module.theta.network_self_link
  description = <<EOD
Self-link of the theta network.
EOD
}

output "theta_subnets" {
  value       = { for k, v in module.theta.subnets : v.region => v.self_link }
  description = <<EOD
Map of region:subnet self-link for theta subnets.
EOD
}
