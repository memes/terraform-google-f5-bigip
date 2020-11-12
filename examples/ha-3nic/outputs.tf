output "instances_self_link" {
  description = <<EOD
Self-link of the BIG-IP instances.
EOD
  value       = module.ha.self_links
}
