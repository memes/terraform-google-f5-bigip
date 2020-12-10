output "do_payloads" {
  value       = local.do_payloads
  description = <<EOD
A list of generated Declarative Onboarding JSON payloads.
EOD
}

output "jq_filter" {
  value       = file("${path.module}/files/do_replace_filter.jq")
  description = <<EOD
A JQ filter that can replace missing IP addresss, networks, and MTUs in DO
payload generated from this module.
EOD
}
