output "self_link" {
  value       = google_compute_instance_template.bigip.self_link
  description = <<EOD
The self-link of the BIG-IP instance template.
EOD
}
