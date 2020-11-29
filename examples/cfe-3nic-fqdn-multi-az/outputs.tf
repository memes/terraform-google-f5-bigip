output "instances_self_link" {
  description = <<EOD
Self-link of the BIG-IP instances.
EOD
  value       = module.cfe.self_links
}
