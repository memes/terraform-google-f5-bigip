output "self_links" {
  description = <<EOD
Self-link of the BIG-IP instances.
EOD
  value       = module.instance.self_links
}
