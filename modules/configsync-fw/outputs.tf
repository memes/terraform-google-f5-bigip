output "management_self_link" {
  value       = google_compute_firewall.mgt_sync.self_link
  description = <<EOD
The self-link for the ConfigSync firewall rule added to management network.
EOD
}

output "dataplane_self_link" {
  value       = google_compute_firewall.data_sync.self_link
  description = <<EOD
The self-link for the ConfigSync firewall rule added to data-plane network.
EOD
}
