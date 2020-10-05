/*XXX
output "self_links" {
  value       = [for vm in google_compute_instance.bigip : vm.self_link]
  description = <<EOD
A list of self-links of the BIG-IP instances, as of RMIG creation.
EOD
}

output "external_addresses" {
  value       = flatten([for vm in google_compute_instance.bigip : [vm.network_interface[0].network_ip, [for alias in vm.network_interface[0].alias_ip_range : alias.ip_cidr_range]]])
  description = <<EOD
A list of the IP addresses and alias CIDRs assigned to instances on the external
NIC.
EOD
}

output "external_vips" {
  value       = flatten([for vm in google_compute_instance.bigip : [for alias in vm.network_interface[0].alias_ip_range : alias.ip_cidr_range]])
  description = <<EOD
A list of IP CIDRs assigned to instances on the external NIC, which usually
corresponds to the VIPs defined on each instance.
EOD
}

output "management_addresses" {
  value       = var.management_subnetwork != "" ? flatten([for vm in google_compute_instance.bigip : [element(vm.network_interface, 1).network_ip, [for alias in element(vm.network_interface, 1).alias_ip_range : alias.ip_cidr_range]]]) : []
  description = <<EOD
A list of the IP addresses and alias CIDRs assigned to instances on the
management NIC, if present.
EOD
}

output "internal_addresses" {
  value       = length(var.internal_subnetworks) > 0 ? flatten([for vm in google_compute_instance.bigip : [for iface in range(2, length(vm.network_interface)) : [element(vm.network_interface, iface).network_ip, [for alias in element(vm.network_interface, iface).alias_ip_range : alias.ip_cidr_range]]]]) : []
  description = <<EOD
A list of the IP addresses and alias CIDRs assigned to instances on the internal
NICs, if present.
EOD
}


output "instance_addresses" {
  value = { for vm in google_compute_instance.bigip : vm.name => {
    external   = concat([vm.network_interface[0].network_ip], [for alias in vm.network_interface[0].alias_ip_range : alias.ip_cidr_range])
    management = length(vm.network_interface) > 1 ? concat([vm.network_interface[1].network_ip], [for alias in vm.network_interface[1].alias_ip_range : alias.ip_cidr_range]) : []
    internal   = length(vm.network_interface) > 2 ? flatten([for iface in range(2, length(vm.network_interface)) : concat([vm.network_interface[iface].network_ip], [for alias in vm.network_interface[iface].alias_ip_range : alias.ip_cidr_range])]) : []
    vips       = [for alias in vm.network_interface[0].alias_ip_range : alias.ip_cidr_range]
  } }
  description = <<EOD
A map of instance name to assigned IP addresses and alias CIDRs.
EOD
}

output "external_public_ips" {
  value       = compact(flatten([for vm in google_compute_instance.bigip : [for ac in vm.network_interface[0].access_config : ac.nat_ip]]))
  description = <<EOD
A list of the public IP addresses assigned to instances on the external NIC.
EOD
}


output "management_public_ips" {
  value       = compact(flatten([for vm in google_compute_instance.bigip : length(vm.network_interface) > 1 ? [for ac in element(vm.network_interface, 1).access_config : ac.nat_ip] : []]))
  description = <<EOD
A list of the public IP addresses assigned to instances on the management NIC,
if present.
EOD
}

output "internal_public_ips" {
  value       = compact(flatten([for vm in google_compute_instance.bigip : length(vm.network_interface) > 2 ? [for iface in range(2, length(vm.network_interface)) : [for ac in element(vm.network_interface, iface).access_config : ac.nat_ip]] : []]))
  description = <<EOD
A list of the public IP addresses assigned to instances on the internal NICs,
if present.
EOD
}
*/
