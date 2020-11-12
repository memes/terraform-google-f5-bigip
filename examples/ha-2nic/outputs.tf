output "instance_self_links" {
  description = <<EOD
Self-link of the BIG-IP instances.
EOD
  value       = module.ha.self_links
}
