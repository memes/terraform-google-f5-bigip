terraform {
  required_version = "> 0.12"
}

# Build a set of Declarative Onboarding files
locals {
  empty = {}
  do_payloads = [for i in range(0, var.num_instances) : templatefile("${path.module}/templates/do.json",
    {
      allow_phone_home = var.allow_phone_home,
      hostname         = length(var.hostnames) > i ? element(var.hostnames, i) : "",
      extramb          = var.extramb,
      ntp_servers      = var.ntp_servers,
      dns_servers      = var.dns_servers,
      search_domains   = var.search_domains,
      timezone         = var.timezone,
      modules          = var.modules,
      # Only include dynamic interfaces if there is > 1 nic on the VMs
      interfaces = var.nic_count > 1 ? concat(
        [
          {
            name          = "external"
            tag           = 4093
            num           = "1.0"
            address       = length(var.external_subnetwork_network_ips) > i ? format("%s/32", element(var.external_subnetwork_network_ips, i)) : "replace"
            allow_service = lookup(var.allow_service, "external", "default")
          }
        ],
        [for j in range(2, var.nic_count) :
          {
            name          = j == 2 ? "internal" : format("internal%d", j - 2)
            tag           = 4094 - j
            num           = format("1.%d", j)
            address       = coalesce(length(var.internal_subnetwork_network_ips) > i ? (length(element(var.internal_subnetwork_network_ips, i)) > j - 2 ? format("%s/32", element(element(var.internal_subnetwork_network_ips, i), j - 2)) : "") : "", "replace")
            allow_service = lookup(var.allow_service, j == 2 ? "internal" : format("internal%d", j - 2), "none")
          }
        ]
      ) : []
      default_gw_address = coalesce(var.default_gateway, "replace")
      additional_config  = length(var.additional_configs) > 0 ? element(var.additional_configs, i) : ""
    }
  )]
}
