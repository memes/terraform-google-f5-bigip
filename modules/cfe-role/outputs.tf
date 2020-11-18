output "qualified_role_id" {
  value       = format(var.target_type == "org" ? "organizations/%s/roles/%s" : "projects/%s/roles/%s", var.target_id, module.cfe_role.custom_role_id)
  description = <<EOD
The qualified role-id for the custom CFE role.
EOD
}
