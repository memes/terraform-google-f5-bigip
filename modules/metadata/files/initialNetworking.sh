#!/bin/sh
# shellcheck disable=SC1091
#
# Setup networking based on boot-time configuration of attached nics

if [ -f /config/cloud/gce/setupUtils.sh ]; then
    . /config/cloud/gce/setupUtils.sh
else
    echo "${GCE_LOG_TS:+"$(date +%Y-%m-%dT%H:%M:%S.%03N%z): "}$0: ERROR: unable to source /config/cloud/gce/setupUtils.sh" >&2
    [ -e /dev/ttyS0 ] && \
        echo "$(date +%Y-%m-%dT%H:%M:%S.%03N%z): $0: ERROR: unable to source /config/cloud/gce/setupUtils.sh" >/dev/ttyS0
    exit 1
fi

info "Waiting for mcpd to be ready"
. /usr/lib/bigstart/bigip-ready-functions
wait_bigip_ready

[ -f /config/cloud/gce/network.config ] && . /config/cloud/gce/network.config

# Only reset the interfaces if there is >1 NIC defined
if [ "${NIC_COUNT:-0}" -gt 1 ]; then
    info "Resetting management settings"
    tmsh modify sys global-settings mgmt-dhcp disabled
    tmsh delete sys management-route all
    tmsh delete sys management-ip all
    info "Resetting all routes"
    tmsh delete net route all
    info "Resetting all self addresses"
    tmsh delete net self all
    info "Resetting all vlans"
    tmsh delete net vlan all
    if [ -n "${MGMT_ADDRESS}" ] && [ -n "${MGMT_GATEWAY}" ] && [ -n "${MGMT_NETWORK}" ] && [ -n "${MGMT_MASK}" ]; then
        info "Configuring management interface"
        tmsh create sys management-ip "${MGMT_ADDRESS}/32"
        tmsh create sys management-route mgmt_gw network "${MGMT_GATEWAY}/32" type interface mtu "${MGMT_MTU:-1460}"
        tmsh create sys management-route mgmt_net network "${MGMT_NETWORK}/${MGMT_MASK}" gateway "${MGMT_GATEWAY}" mtu "${MGMT_MTU:-1460}"
        tmsh create sys management-route default gateway "${MGMT_GATEWAY}" mtu "${MGMT_MTU:-1460}"
    fi
fi

# Update common settings
info "Removing DHCP provided ntp servers from management"
# shellcheck disable=SC1083
tmsh modify sys management-dhcp sys-mgmt-dhcp-config request-options delete { ntp-servers }

# Adding GCP metadata server as DNS resolver
info "Adding GCP Metadata service as DNS resolver"
# shellcheck disable=SC1083
tmsh modify sys dns name-servers add { 169.254.169.254 }

# Ensure that there's a DNS mapping for metadata.google.internal
info "Adding remote-host metadata.google.internal"
# shellcheck disable=SC1083
tmsh modify sys global-settings remote-host add { metadata.google.internal { hostname metadata.google.internal addr 169.254.169.254 } }

# Enable SELinux on failover
info "Enabling SELinux on failover scripts"
tmsh modify sys db failover.selinuxallowscripts value enable

info "Disabling gui-setup"
tmsh modify sys global-settings gui-setup disabled

info "Saving config"
tmsh save /sys config

info "Initial networking configuration is complete"
exit 0
