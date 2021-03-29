#!/bin/sh
# shellcheck disable=SC1091
#
# This script will perform base configuration of BIG-IP on the first or second
# boot. It is intended to be idempotent, but ideally should only be run once -
# or twice when a management nic swap occurs.

if [ -f /config/cloud/gce/setupUtils.sh ]; then
    . /config/cloud/gce/setupUtils.sh
else
    echo "${GCE_LOG_TS:+"$(date +%Y-%m-%dT%H:%M:%S.%03N%z): "}$0: ERROR: unable to source /config/cloud/gce/setupUtils.sh" >&2
    [ -e /dev/ttyS0 ] && \
        echo "$(date +%Y-%m-%dT%H:%M:%S.%03N%z): $0: ERROR: unable to source /config/cloud/gce/setupUtils.sh" >/dev/ttyS0
    exit 1
fi

info "Initialisation starting"
mkdir -p /config/cloud/gce /var/log/cloud/google

if [ -n "$(get_instance_attribute details_on_error)" ]; then
    touch /var/run/gce_setup_utils_details_on_error
else
    [ -e /var/run/gce_setup_utils_details_on_error ] && \
        rm -f /var/run/gce_setup_utils_details_on_error
fi

# Write the current network configuration to file
info "Generating /config/cloud/gce/network.config"
if [ ! -f /config/cloud/gce/network.config ]; then
    curl -sf --retry 20 'http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/?recursive=true' -H 'Metadata-Flavor: Google' | \
        jq -r '(. | length) as $count |
                to_entries |
                map(.key=(if .key == 0 then "EXT" elif .key == 1 then "MGMT" else "INT\(.key-2)" end)) |
                map(["\(.key)_ADDRESS=\(.value.ip)", "\(.key)_MASK=\(.value.subnetmask)", "\(.key)_GATEWAY=\(.value.gateway)", "\(.key)_NETWORK=$(ipcalc -n \(.value.ip) \(.value.subnetmask) | cut -d= -f2)", "\(.key)_MTU=\(.value.mtu)"]) |
                .+ [["NIC_COUNT=\($count)"]] |
                .+ [(if $count == 1 then ["MGMT_GUI_PORT=8443"] else [] end)] |
                .[] | select (length > 0) | join("\n")' > /config/cloud/gce/network.config
    chmod 0644 /config/cloud/gce/network.config
fi
# The rest of the script will have issues if networking cannot be setup
# correctly; bail out here if network.config is missing
[ -f /config/cloud/gce/network.config ] || \
    error "Run-time network configuration script is missing"
. /config/cloud/gce/network.config

# Block until mcpd is up
info "Waiting for mcpd to be ready"
. /usr/lib/bigstart/bigip-ready-functions
wait_bigip_ready

# Early initialisation
if [ ! -f /config/cloud/gce/earlySetupComplete ]; then
    [ -x /config/cloud/gce/earlySetup.sh ] || \
        error "/config/cloud/gce/earlySetup.sh is missing"
    /config/cloud/gce/earlySetup.sh || \
        error "earlySetup script failed with exit code: $?"
    touch /config/cloud/gce/earlySetupComplete
fi

# Switch management nic as needed; this may reboot the instance
# Do this early in case the customer's networking prohibts onboarding through
# nic0. E.g. internal repos only available on management network, etc.
if [ -x /config/cloud/gce/multiNicMgmtSwap.sh ]; then
    /config/cloud/gce/multiNicMgmtSwap.sh || \
        error "stopping initial setup for reboot"
fi

# Execute initial networking configuration; this will use the values in
# network.config to setup the interfaces to a known configuration. Should only
# be executed once as it will overwrite/reset any post-install configurations.
if [ ! -f /config/cloud/gce/initialNetworkingComplete ]; then
    [ -x /config/cloud/gce/initialNetworking.sh ] || \
        error "/config/cloud/gce/initialNetworking.sh is missing"
    /config/cloud/gce/initialNetworking.sh || \
        error "initialNetworking script failed with exit code: $?"
    touch /config/cloud/gce/initialNetworkingComplete
fi

# Change the admin password, if available in Secrets Manager. Only do this once
# to avoid resetting a customer password change.
if [ ! -f /config/cloud/gce/adminPasswordChanged ]; then
    ADMIN_PASSWORD="$(get_secret admin_password_key)"
    if [ -n "${ADMIN_PASSWORD}" ]; then
        info "Changing admin password"
        # shellcheck disable=SC2086
        if tmsh modify auth user admin password \'${ADMIN_PASSWORD}\'; then
            touch /config/cloud/gce/adminPasswordChanged
            info "Admin password has been changed"
        else
            error "Error changing admin password: tmsh exit code $?"
        fi
    else
        info "Unable to get admin password from secrets manager; setup script will continue but some functionality may be broken"
    fi
fi
ADMIN_PASSWORD=""

# Install cloud libraries
if [ ! -f /config/cloud/gce/installCloudLibsComplete ]; then
    [ -x /config/cloud/gce/installCloudLibs.sh ] || \
        error "/config/cloud/gce/installCloudLibs.sh is missing"
    # Install any cloud libraries that are specified in the instance metadata
    # shellcheck disable=SC2046
    /config/cloud/gce/installCloudLibs.sh $(get_instance_attribute install_cloud_libs) || \
        error "installCloudLibs script failed with exit code: $?"
    touch /config/cloud/gce/installCloudLibsComplete
fi

# Apply Declarative Onboarding content
if [ ! -f /config/cloud/gce/declarativeOnboardingComplete ]; then
    [ -x /config/cloud/gce/declarativeOnboarding.sh ] || \
        error "/config/cloud/gce/declarativeOnboarding.sh is missing"
    /config/cloud/gce/declarativeOnboarding.sh "$(get_instance_attribute do_payload)" || \
        error "declarativeOnboarding script failed with exit code: $?"
    touch /config/cloud/gce/declarativeOnboardingComplete
fi

# Apply AS3 content
if [ ! -f /config/cloud/gce/as3Complete ]; then
    [ -x /config/cloud/gce/applicationServices3.sh ] || \
        error "/config/cloud/gce/applicationServices3.sh is missing"
    /config/cloud/gce/applicationServices3.sh "$(get_instance_attribute as3_payload)" || \
        error "applicationServices3 script failed with exit code: $?"
    touch /config/cloud/gce/as3Complete
fi

# Execute custom script; note there is no sentinel file for this, supplier of
# custom script must make it idempotent as needed.
if [ -x /config/cloud/gce/customConfig.sh ]; then
    info "About to execute custom configuration script"
    /config/cloud/gce/customConfig.sh || \
        info "customConfig script returned error $?"
fi

if [ -f /etc/systemd/system/f5-gce-initial-setup.service ]; then
    info "Actions complete: disabling f5-gce-initial-setup.service unit"
    systemctl disable f5-gce-initial-setup.service
fi
if [ -f /etc/systemd/system/f5-gce-management-route.service ]; then
    info "Actions complete: enabling f5-gce-management-route.service for future boot"
    systemctl enable f5-gce-management-route.service
fi
info "Initialisation complete"
