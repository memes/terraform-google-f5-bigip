terraform {
  required_version = "~> 0.13.5"
}

# Build a set of Declarative Onboarding files
locals {
  empty = {}
  do_payloads = [for i in range(0, var.num_instances) : templatefile("${path.module}/templates/do.json",
    {
      allow_phone_home = var.allow_phone_home,
      hostname         = length(var.hostnames) > i ? element(var.hostnames, i) : "",
      ntp_servers      = var.ntp_servers,
      dns_servers      = var.dns_servers,
      search_domains   = var.search_domains,
      timezone         = var.timezone,
      modules          = var.modules,
      interfaces = concat(
        [
          {
            name          = "external"
            tag           = 4093
            num           = "1.0"
            address       = length(var.external_subnetwork_network_ips) > i ? element(var.external_subnetwork_network_ips, i) : "replace"
            allow_service = "default"
            public = var.provision_external_public_ip ? {
              address       = "replace"
              allow_service = "default"
            } : {}
            vips = length(var.external_subnetwork_vip_cidrs) > i ? element(var.external_subnetwork_vip_cidrs, i) : []
          }
        ],
        [for j in range(0, var.internal_nic_count) :
          {
            name          = j == 0 ? "internal" : format("internal%d", i)
            tag           = 4092 - j
            num           = format("1.%d", j + 2)
            address       = coalesce(length(var.internal_subnetwork_network_ips) > i ? (length(element(var.internal_subnetwork_network_ips, i)) > j ? element(element(var.internal_subnetwork_network_ips, i), j) : "") : "", "replace")
            allow_service = "none"
            public = var.provision_internal_public_ip ? {
              address       = "replace"
              allow_service = "none"
            } : {}
            vips = length(var.internal_subnetwork_vip_cidrs) > i ? element(var.internal_subnetwork_vip_cidrs, i) : []
          }
        ]
      )
    }
  )]
}
