output "bastion_name" {
  value       = module.bastion.hostname
  description = <<EOD
The name of the bastion VM.
EOD
}

output "bigip_sa" {
  value       = module.service_accounts.emails["bigip"]
  description = <<EOD
The fully-qualified service account email to use with BIG-IP instances.
EOD
}

output "alpha_west" {
  value       = module.alpha.subnets["us-west1/alpha-west"].self_link
  description = <<EOD
Alpha us-west1 subnet self-link.
EOD
}

output "beta_west" {
  value       = module.beta.subnets["us-west1/beta-west"].self_link
  description = <<EOD
beta us-west1 subnet self-link.
EOD
}

output "gamma_west" {
  value       = module.gamma.subnets["us-west1/gamma-west"].self_link
  description = <<EOD
gamma us-west1 subnet self-link.
EOD
}

output "delta_west" {
  value       = module.delta.subnets["us-west1/delta-west"].self_link
  description = <<EOD
delta us-west1 subnet self-link.
EOD
}

output "epsilon_west" {
  value       = module.epsilon.subnets["us-west1/epsilon-west"].self_link
  description = <<EOD
epsilon us-west1 subnet self-link.
EOD
}

output "zeta_west" {
  value       = module.zeta.subnets["us-west1/zeta-west"].self_link
  description = <<EOD
zeta us-west1 subnet self-link.
EOD
}

output "eta_west" {
  value       = module.eta.subnets["us-west1/eta-west"].self_link
  description = <<EOD
eta us-west1 subnet self-link.
EOD
}

output "theta_west" {
  value       = module.theta.subnets["us-west1/theta-west"].self_link
  description = <<EOD
theta us-west1 subnet self-link.
EOD
}
