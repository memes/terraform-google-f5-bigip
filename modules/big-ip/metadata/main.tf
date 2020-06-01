terraform {
  required_version = "~> 0.12"
  required_providers {
    google = ">= 3.19"
  }
  experiments = [variable_validation]
}

# Apply any required changes to metadata
locals {
  empty = {}
  as3_payload = var.as3_payload != "" ? var.as3_payload : templatefile("${path.module}/templates/as3.json",
    {}
  )
  do_payload = var.do_payload != "" ? var.do_payload : templatefile("${path.module}/templates/do.json",
    {
      allow_phone_home  = var.allow_phone_home,
      ntp_servers       = var.ntp_servers,
      timezone          = var.timezone,
      modules           = [for module in var.modules : split(":", module)],
      analytics_metrics = format("cloudName:google,templateName:emes,templateVersion:0.0.1,region:%s,bigipVersion:%s,licenseType:%s", var.region, var.image, var.license_type)
    }
  )
  custom_script = "${path.module}/files/customConfig.sh"
  startup = templatefile(var.use_cloud_init ? "${path.module}/templates/cloud_config.yml" : "${path.module}/templates/startup_script.sh",
    {
      setup_utils_sh            = base64gzip(file("${path.module}/files/setupUtils.sh")),
      multi_nic_mgt_swap_sh     = base64gzip(file("${path.module}/files/multiNicMgmtSwap.sh")),
      initial_networking_sh     = base64gzip(file("${path.module}/files/initialNetworking.sh")),
      verify_hash_tcl           = base64gzip(file("${path.module}/files/verifyHash")),
      install_cloud_libs_sh     = base64gzip(file("${path.module}/files/installCloudLibs.sh")),
      reset_management_route_sh = base64gzip(file("${path.module}/files/resetManagementRoute.sh")),
      initial_setup_sh          = base64gzip(file("${path.module}/files/initialSetup.sh")),
      application_services3_sh  = base64gzip(file("${path.module}/files/applicationServices3.sh")),
      declarative_onboarding_sh = base64gzip(file("${path.module}/files/declarativeOnboarding.sh")),
      custom_config_sh          = base64gzip(file(local.custom_script)),
    }
  )
  cloud_init = {
    user-data = local.startup
  }
  startup_script = {
    startup-script = local.startup
  }
  ssh_keys = {
    ssh-keys = var.ssh_keys
  }
  metadata = merge(var.metadata,
    {
      enable-oslogin     = upper(var.enable_os_login)
      serial-port-enable = upper(var.enable_serial_console)
      shutdown-script = templatefile("${path.module}/templates/shutdown_script.sh",
        {
        }
      )
      default_gateway       = var.default_gateway
      install_cloud_libs    = join(" ", var.install_cloud_libs)
      allow_usage_analytics = upper(var.allow_usage_analytics)
      admin_password_key    = var.admin_password_secret_manager_key
      as3_payload           = base64gzip(local.as3_payload)
      do_payload            = base64gzip(local.do_payload)
    },
    var.ssh_keys != "" ? local.ssh_keys : local.empty,
    var.use_cloud_init ? local.cloud_init : local.startup_script,
  )
}
