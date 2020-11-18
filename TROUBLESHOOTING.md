# Troubleshooting BIG-IP setup

## Boot steps

Regardless of which initialisation method is in use, the boot steps to onboard
and prepare the BIG-IP for use are the same.

<!-- spell-checker: ignore nics -->
1. Swap control-plane and data-plane NICs and reboot

   This is only for VMs with 2 or more VPCs attached; 1 NIC instances will not
   reboot

2. Configure base networking

   Add a self-ip and required routes to each interface known at boot; this
   script will not configure VIPs or floating IPs

3. Set admin password from Secret Manager

4. Install supporting cloud libraries

   By default, these will be pulled from official F5 sources, but alternate URLs
   can be supplied to override these locations.

5. Apply DO declaration

6. Apply AS3 declaration

7. Execute custom setup script

   By default, this script is a no-operation starting point for end-user
   customisations that cannot be handled by DO or AS3 declarations. The exception
   is that the CFE module uses a custom script to apply CFE configuration.

8. Reset management gateway configuration

   Only for 2 or more NIC instances; `cloud-init` option will install a dedicated
   systemd service unit to perform just this step on subsequent boots, whereas
   the default metadata startup-script will execute on every boot. See
   [KB85830674](https://support.f5.com/csp/article/K85730674) for details on the
   underlying issue.

## Debugging the boot process

During boot, the initialisation scripts will produce logging output for review.
With the default startup option (metadata startup shell script), output is sent
to `/var/log/cloud/google/startup-script.log` through shell redirection.

<!-- spell-checker: ignore journald -->
If the BIG-IP is initialised through `cloud-init`, systemd service units are
installed to orchestrate onboarding and all output is logged via journald.

> **NOTE:** See [CONFIGURATION](/CONFIGURATION.md) for full details of the
> run-time initialisation choices.

<!-- spell-checker: ignore markdownlint -->
<!-- markdownlint-disable MD033 -->
|Boot option|Logging mechanism|
|-----------|-----------------|
|metadata startup-script (default)|`/var/log/cloud/google/startup-script.log`|
|`cloud-init`|Unit journal file<br/>`journalctl -u f5-gce-initial-setup.service`<br/>`journalctl -u f5-gce-management-route.service`|
<!-- markdownlint-enable MD033 -->

In addition to the log files above, the boot scripts will write progress to the
serial console as well. This way you can determine where a script failed even if
you cannot login to the instance via SSH or serial console. Serial console output
can be seen in the web GUI:

![gui-serial-console](images/serial-console.png)

Or via `gcloud` command line (replace PROJECT, ZONE, VM_NAME appropriately):

<!-- spell-checker: disable -->
```shell
gcloud compute instances get-serial-port-output --project PROJECT --zone ZONE VM_NAME 2>/dev/null | grep '/config/cloud/gce'
```

```text
2020-09-10T11:12:25.005-0700: /config/cloud/gce/initialSetup.sh: Info: Initialisation starting
2020-09-10T11:12:25.019-0700: /config/cloud/gce/initialSetup.sh: Info: Generating /config/cloud/gce/network.config
2020-09-10T11:12:25.165-0700: /config/cloud/gce/initialSetup.sh: Info: Waiting for mcpd to be ready
2020-09-10T11:13:14.218-0700: /config/cloud/gce/multiNicMgmtSwap.sh: Rebooting for multi-nic management interface swap
2020-09-10T11:13:56.772-0700: /config/cloud/gce/initialSetup.sh: Info: Initialisation starting
2020-09-10T11:13:56.776-0700: /config/cloud/gce/initialSetup.sh: Info: Generating /config/cloud/gce/network.config
2020-09-10T11:13:56.786-0700: /config/cloud/gce/initialSetup.sh: Info: Waiting for mcpd to be ready
2020-09-10T11:14:24.846-0700: /config/cloud/gce/multiNicMgmtSwap.sh: Nothing to do
2020-09-10T11:14:24.852-0700: /config/cloud/gce/initialNetworking.sh: Info: Waiting for mcpd to be ready
2020-09-10T11:14:25.244-0700: /config/cloud/gce/initialNetworking.sh: Info: Resetting management settings
2020-09-10T11:14:26.985-0700: /config/cloud/gce/initialNetworking.sh: Info: Resetting all routes
2020-09-10T11:14:27.428-0700: /config/cloud/gce/initialNetworking.sh: Info: Resetting all self addresses
2020-09-10T11:14:27.814-0700: /config/cloud/gce/initialNetworking.sh: Info: Resetting all vlans
2020-09-10T11:14:28.205-0700: /config/cloud/gce/initialNetworking.sh: Info: Configuring management interface
2020-09-10T11:14:31.489-0700: /config/cloud/gce/initialNetworking.sh: Info: Configuring external interface
2020-09-10T11:14:33.713-0700: /config/cloud/gce/initialNetworking.sh: Info: Configuring internal interface
2020-09-10T11:14:35.762-0700: /config/cloud/gce/initialNetworking.sh: Info: Setting default gateway to 172.16.0.1
2020-09-10T11:14:36.374-0700: /config/cloud/gce/initialNetworking.sh: Info: Removing DHCP provided ntp servers from management
2020-09-10T11:14:37.308-0700: /config/cloud/gce/initialNetworking.sh: Info: Adding GCP Metadata service as DNS resolver
2020-09-10T11:14:38.503-0700: /config/cloud/gce/initialNetworking.sh: Info: Saving config
2020-09-10T11:14:42.461-0700: /config/cloud/gce/initialNetworking.sh: Info: Initial networking configuration is complete
2020-09-10T11:14:45.486-0700: /config/cloud/gce/initialSetup.sh: Info: Curl failed with exit code 7; sleeping before retry
2020-09-10T11:14:55.860-0700: /config/cloud/gce/initialSetup.sh: Info: Changing admin password
2020-09-10T11:14:56.522-0700: /config/cloud/gce/initialSetup.sh: Info: Admin password has been changed
2020-09-10T11:14:56.612-0700: /config/cloud/gce/installCloudLibs.sh: Info: waiting for mcpd
2020-09-10T11:14:57.527-0700: /config/cloud/gce/installCloudLibs.sh: Info: Getting admin password
2020-09-10T11:14:57.813-0700: /config/cloud/gce/installCloudLibs.sh: Info: loading verifyHash script
2020-09-10T11:14:58.435-0700: /config/cloud/gce/installCloudLibs.sh: Info: loaded verifyHash
2020-09-10T11:14:58.441-0700: /config/cloud/gce/installCloudLibs.sh: Info: Downloading https://cdn.f5.com/product/cloudsolutions/f5-cloud-libs/v4.22.0/f5-cloud-libs.tar.gz to /var/tmp/f5-cloud-libs.tar.gz
2020-09-10T11:14:58.931-0700: /config/cloud/gce/installCloudLibs.sh: Info: Verifying f5-cloud-libs.tar.gz
2020-09-10T11:14:59.750-0700: /config/cloud/gce/installCloudLibs.sh: Info: verified /var/tmp/f5-cloud-libs.tar.gz
2020-09-10T11:14:59.753-0700: /config/cloud/gce/installCloudLibs.sh: Info: Expanding /var/tmp/f5-cloud-libs.tar.gz
2020-09-10T11:14:59.801-0700: /config/cloud/gce/installCloudLibs.sh: Info: Downloading https://cdn.f5.com/product/cloudsolutions/f5-cloud-libs-gce/v2.6.0/f5-cloud-libs-gce.tar.gz to /var/tmp/f5-cloud-libs-gce.tar.gz
2020-09-10T11:15:00.234-0700: /config/cloud/gce/installCloudLibs.sh: Info: Verifying f5-cloud-libs-gce.tar.gz
2020-09-10T11:15:01.109-0700: /config/cloud/gce/installCloudLibs.sh: Info: verified /var/tmp/f5-cloud-libs-gce.tar.gz
2020-09-10T11:15:01.112-0700: /config/cloud/gce/installCloudLibs.sh: Info: Expanding /var/tmp/f5-cloud-libs-gce.tar.gz
2020-09-10T11:15:01.372-0700: /config/cloud/gce/installCloudLibs.sh: Info: Downloading https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.22.1/f5-appsvcs-3.22.1-1.noarch.rpm to /var/tmp/f5-appsvcs-3.22.1-1.noarch.rpm
2020-09-10T11:15:03.083-0700: /config/cloud/gce/installCloudLibs.sh: Info: Don't have a verification hash for f5-appsvcs-3.22.1-1.noarch.rpm
2020-09-10T11:15:03.086-0700: /config/cloud/gce/installCloudLibs.sh: Info: Installing /var/tmp/f5-appsvcs-3.22.1-1.noarch.rpm
2020-09-10T11:15:03.374-0700: /config/cloud/gce/installCloudLibs.sh: Info: Downloading https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.15.0/f5-declarative-onboarding-1.15.0-3.noarch.rpm to /var/tmp/f5-declarative-onboarding-1.15.0-3.noarch.rpm
2020-09-10T11:15:04.591-0700: /config/cloud/gce/installCloudLibs.sh: Info: Don't have a verification hash for f5-declarative-onboarding-1.15.0-3.noarch.rpm
2020-09-10T11:15:04.595-0700: /config/cloud/gce/installCloudLibs.sh: Info: Installing /var/tmp/f5-declarative-onboarding-1.15.0-3.noarch.rpm
2020-09-10T11:15:04.739-0700: /config/cloud/gce/installCloudLibs.sh: Info: Downloading https://github.com/F5Networks/f5-cloud-failover-extension/releases/download/v1.5.0/f5-cloud-failover-1.5.0-0.noarch.rpm to /var/tmp/f5-cloud-failover-1.5.0-0.noarch.rpm
2020-09-10T11:15:06.563-0700: /config/cloud/gce/installCloudLibs.sh: Info: Don't have a verification hash for f5-cloud-failover-1.5.0-0.noarch.rpm
2020-09-10T11:15:06.565-0700: /config/cloud/gce/installCloudLibs.sh: Info: Installing /var/tmp/f5-cloud-failover-1.5.0-0.noarch.rpm
2020-09-10T11:15:06.912-0700: /config/cloud/gce/installCloudLibs.sh: Info: Package f5-appsvcs-3.22.1-1.noarch is installed
2020-09-10T11:15:07.074-0700: /config/cloud/gce/installCloudLibs.sh: Info: Package f5-declarative-onboarding-1.15.0-3.noarch is installed
2020-09-10T11:15:07.244-0700: /config/cloud/gce/installCloudLibs.sh: Info: Package null has status STARTED
2020-09-10T11:15:07.246-0700: /config/cloud/gce/installCloudLibs.sh: Info: Sleeping before reexamining installation tasks
2020-09-10T11:15:12.555-0700: /config/cloud/gce/installCloudLibs.sh: Info: Package f5-cloud-failover-1.5.0-0.noarch is installed
2020-09-10T11:15:12.559-0700: /config/cloud/gce/installCloudLibs.sh: Info: Deleting '/var/tmp/f5-cloud-libs.tar.gz'
2020-09-10T11:15:12.562-0700: /config/cloud/gce/installCloudLibs.sh: Info: Deleting '/var/tmp/f5-cloud-libs-gce.tar.gz'
2020-09-10T11:15:12.565-0700: /config/cloud/gce/installCloudLibs.sh: Info: Deleting '/var/tmp/f5-appsvcs-3.22.1-1.noarch.rpm'
2020-09-10T11:15:12.568-0700: /config/cloud/gce/installCloudLibs.sh: Info: Deleting '/var/tmp/f5-declarative-onboarding-1.15.0-3.noarch.rpm'
2020-09-10T11:15:12.571-0700: /config/cloud/gce/installCloudLibs.sh: Info: Deleting '/var/tmp/f5-cloud-failover-1.5.0-0.noarch.rpm'
2020-09-10T11:15:12.574-0700: /config/cloud/gce/installCloudLibs.sh: Info: Cloud libraries are installed
2020-09-10T11:15:13.097-0700: /config/cloud/gce/declarativeOnboarding.sh: Info: Applying Declarative Onboarding payload
2020-09-10T11:15:13.994-0700: /config/cloud/gce/declarativeOnboarding.sh: Info: Declarative Onboarding is in process
2020-09-10T11:15:13.997-0700: /config/cloud/gce/declarativeOnboarding.sh: Info: Sleeping before rechecking Declarative Onboarding tasks
2020-09-10T11:15:31.061-0700: /config/cloud/gce/declarativeOnboarding.sh: Info: Declarative Onboarding is in process
2020-09-10T11:15:31.065-0700: /config/cloud/gce/declarativeOnboarding.sh: Info: Sleeping before rechecking Declarative Onboarding tasks
2020-09-10T18:15:36.252+0000: /config/cloud/gce/declarativeOnboarding.sh: Info: Declarative Onboarding is in process
2020-09-10T18:15:36.255+0000: /config/cloud/gce/declarativeOnboarding.sh: Info: Sleeping before rechecking Declarative Onboarding tasks
2020-09-10T18:15:41.706+0000: /config/cloud/gce/declarativeOnboarding.sh: Info: Declarative Onboarding is in process
2020-09-10T18:15:41.709+0000: /config/cloud/gce/declarativeOnboarding.sh: Info: Sleeping before rechecking Declarative Onboarding tasks
2020-09-10T18:15:46.899+0000: /config/cloud/gce/declarativeOnboarding.sh: Info: Declarative Onboarding is in process
2020-09-10T18:15:46.903+0000: /config/cloud/gce/declarativeOnboarding.sh: Info: Sleeping before rechecking Declarative Onboarding tasks
2020-09-10T18:15:52.092+0000: /config/cloud/gce/declarativeOnboarding.sh: Info: Declarative Onboarding is in process
2020-09-10T18:15:52.095+0000: /config/cloud/gce/declarativeOnboarding.sh: Info: Sleeping before rechecking Declarative Onboarding tasks
2020-09-10T18:16:14.225+0000: /config/cloud/gce/declarativeOnboarding.sh: Info: Declarative Onboarding is in process
2020-09-10T18:16:14.229+0000: /config/cloud/gce/declarativeOnboarding.sh: Info: Sleeping before rechecking Declarative Onboarding tasks
2020-09-10T18:16:19.447+0000: /config/cloud/gce/declarativeOnboarding.sh: Info: Declarative Onboarding is complete
2020-09-10T18:16:20.068+0000: /config/cloud/gce/applicationServices3.sh: Info: Applying AS3 payload
2020-09-10T18:16:20.512+0000: /config/cloud/gce/applicationServices3.sh: Info: AS3 payload is being processed
2020-09-10T18:16:20.515+0000: /config/cloud/gce/applicationServices3.sh: Info: Sleeping before rechecking AS3 tasks
2020-09-10T18:16:25.706+0000: /config/cloud/gce/applicationServices3.sh: Info: AS3 payload is installed
2020-09-10T18:16:25.711+0000: /config/cloud/gce/initialSetup.sh: Info: About to execute custom configuration script
2020-09-10T18:16:25.721+0000: /config/cloud/gce/customConfig.sh: Info: waiting for mcpd to be ready
2020-09-10T18:16:26.193+0000: /config/cloud/gce/customConfig.sh: Info: Disabling gui-setup
2020-09-10T18:16:26.791+0000: /config/cloud/gce/customConfig.sh: Info: Saving system config
2020-09-10T18:16:31.618+0000: /config/cloud/gce/customConfig.sh: Info: Custom configuration is complete
2020-09-10T18:16:31.622+0000: /config/cloud/gce/initialSetup.sh: Info: Initialisation complete
2020-09-10T18:16:31.632+0000: /config/cloud/gce/resetManagementRoute.sh: waiting for mcpd to be ready
2020-09-10T18:16:32.644+0000: /config/cloud/gce/resetManagementRoute.sh: complete
```
<!-- spell-checker: enable -->

### Re-executing boot scripts

The boot scripts are modular and designed to be re-executable in the event of a
configuration failure. Should a [step](#boot-steps) fail, the entire
initialisation script can be re-executed from an elevated BASH shell; items that
have already been completed will be skipped, and only the incomplete steps will
be re-executed.

<!-- spell-checker: disable -->
```shell
admin@(isolated-vpcs-bigip-1)(cfg-sync In Sync)(Active)(/Common)(tmos)# bash
[admin@isolated-vpcs-bigip-1:Active:In Sync] ~ # sudo sh /config/cloud/gce/initialSetup.sh
```

```text
/config/cloud/gce/initialSetup.sh: Info: Initialisation starting
/config/cloud/gce/initialSetup.sh: Info: Generating /config/cloud/gce/network.config
/config/cloud/gce/initialSetup.sh: Info: Waiting for mcpd to be ready
...
/config/cloud/gce/initialSetup.sh: Info: Initialisation complete
```
<!-- spell-checker: enable -->
