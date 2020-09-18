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
        tmsh create sys management-route mgmt_gw network "${MGMT_GATEWAY}/32" type interface mtu 1460
        tmsh create sys management-route mgmt_net network "${MGMT_NETWORK}/${MGMT_MASK}" gateway "${MGMT_GATEWAY}" mtu 1460
        tmsh create sys management-route default gateway "${MGMT_GATEWAY}" mtu 1460
    fi
    if [ -n "${EXT_ADDRESS}" ] && [ -n "${EXT_GATEWAY}" ] && [ -n "${EXT_NETWORK}" ] && [ -n "${EXT_MASK}" ]; then
        info "Configuring external interface"
        # shellcheck disable=SC1083
        tmsh create net vlan external interfaces add { 1.0 } mtu 1460
        tmsh create net self self_external address "${EXT_ADDRESS}/32" vlan external ${EXT_ALLOW_SERVICE:+allow-service ${EXT_ALLOW_SERVICE}}
        tmsh create net route ext_gw_interface network "${EXT_GATEWAY}/32" interface external
        tmsh create net route ext_rt network "${EXT_NETWORK}/${EXT_MASK}" gw "${EXT_GATEWAY}"
    fi
    # 3+ NIC configuration
    if [ -n "${INT0_ADDRESS}" ] && [ -n "${INT0_GATEWAY}" ] && [ -n "${INT0_NETWORK}" ] && [ -n "${INT0_MASK}" ]; then
        info "Configuring internal interface"
        # shellcheck disable=SC1083
        tmsh create net vlan internal interfaces add { 1.2 } mtu 1460
        tmsh create net self self_internal address "${INT0_ADDRESS}/32" vlan internal ${INT0_ALLOW_SERVICE:+allow-service ${INT0_ALLOW_SERVICE}}
        tmsh create net route int_gw_interface network "${INT0_GATEWAY}/32" interface internal
        tmsh create net route int_rt network "${INT0_NETWORK}/${INT0_MASK}" gw "${INT0_GATEWAY}"
    fi
    # 4+ NIC configuration
    if [ -n "${INT1_ADDRESS}" ] && [ -n "${INT1_GATEWAY}" ] && [ -n "${INT1_NETWORK}" ] && [ -n "${INT1_MASK}" ]; then
        info "Configuring secondary internal interface (internal1)"
        # shellcheck disable=SC1083
        tmsh create net vlan internal1 interfaces add { 1.3 } mtu 1460
        tmsh create net self self_internal1 address "${INT1_ADDRESS}/32" vlan internal1 ${INT1_ALLOW_SERVICE:+allow-service ${INT1_ALLOW_SERVICE}}
        tmsh create net route int_gw_interface1 network "${INT1_GATEWAY}/32" interface internal1
        tmsh create net route int_rt1 network "${INT1_NETWORK}/${INT1_MASK}" gw "${INT1_GATEWAY}"
    fi
    if [ -n "${INT2_ADDRESS}" ] && [ -n "${INT2_GATEWAY}" ] && [ -n "${INT2_NETWORK}" ] && [ -n "${INT2_MASK}" ]; then
        info "Configuring tertiary internal interface (internal2)"
        # shellcheck disable=SC1083
        tmsh create net vlan internal2 interfaces add { 1.4 } mtu 1460
        tmsh create net self self_internal2 address "${INT2_ADDRESS}/32" vlan internal2 ${INT2_ALLOW_SERVICE:+allow-service ${INT2_ALLOW_SERVICE}}
        tmsh create net route int_gw_interface2 network "${INT2_GATEWAY}/32" interface internal2
        tmsh create net route int_rt2 network "${INT2_NETWORK}/${INT2_MASK}" gw "${INT2_GATEWAY}"
    fi
    if [ -n "${INT3_ADDRESS}" ] && [ -n "${INT3_GATEWAY}" ] && [ -n "${INT3_NETWORK}" ] && [ -n "${INT3_MASK}" ]; then
        info "Configuring quaternary internal interface (internal3)"
        # shellcheck disable=SC1083
        tmsh create net vlan internal3 interfaces add { 1.5 } mtu 1460
        tmsh create net self self_internal3 address "${INT3_ADDRESS}/32" vlan internal3 ${INT3_ALLOW_SERVICE:+allow-service ${INT3_ALLOW_SERVICE}}
        tmsh create net route int_gw_interface3 network "${INT3_GATEWAY}/32" interface internal3
        tmsh create net route int_rt3 network "${INT3_NETWORK}/${INT3_MASK}" gw "${INT3_GATEWAY}"
    fi
    if [ -n "${INT4_ADDRESS}" ] && [ -n "${INT4_GATEWAY}" ] && [ -n "${INT4_NETWORK}" ] && [ -n "${INT4_MASK}" ]; then
        info "Configuring quinary internal interface (internal4)"
        # shellcheck disable=SC1083
        tmsh create net vlan internal4 interfaces add { 1.6 } mtu 1460
        tmsh create net self self_internal4 address "${INT4_ADDRESS}/32" vlan internal4 ${INT4_ALLOW_SERVICE:+allow-service ${INT4_ALLOW_SERVICE}}
        tmsh create net route int_gw_interface4 network "${INT4_GATEWAY}/32" interface internal4
        tmsh create net route int_rt network4 "${INT4_NETWORK}/${INT4_MASK}" gw "${INT4_GATEWAY}"
    fi
    if [ -n "${INT5_ADDRESS}" ] && [ -n "${INT5_GATEWAY}" ] && [ -n "${INT5_NETWORK}" ] && [ -n "${INT5_MASK}"  ]; then
        info "Configuring senary internal interface (internal5)"
        # shellcheck disable=SC1083
        tmsh create net vlan internal5 interfaces add { 1.7 } mtu 1460
        tmsh create net self self_internal5 address "${INT5_ADDRESS}/32" vlan internal5 ${INT5_ALLOW_SERVICE:+allow-service ${INT5_ALLOW_SERVICE}}
        tmsh create net route int_gw_interface5 network "${INT5_GATEWAY}/32" interface internal5
        tmsh create net route int_rt network5 "${INT5_NETWORK}/${INT5_MASK}" gw "${INT5_GATEWAY}"
    fi

    # Add a default route - this may faigive a warning message if there isn't a
    # matching nic - with fallback to NIC0 gateway
    # shellcheck disable=SC2154
    info "Setting default gateway to ${DEFAULT_GATEWAY:-${EXT_GATEWAY}}"
    tmsh create net route default gw "${DEFAULT_GATEWAY:-${EXT_GATEWAY}}"
fi

# Update common settings
info "Removing DHCP provided ntp servers from management"
# shellcheck disable=SC1083
tmsh modify sys management-dhcp sys-mgmt-dhcp-config request-options delete { ntp-servers }

# Adding GCP metadata server as DNS resolver
info "Adding GCP Metadata service as DNS resolver"
# shellcheck disable=SC1083
tmsh modify sys dns name-servers add { 169.254.169.254 }

# Enable SELinux on failover
info "Enabling SELinux on failover scripts"
tmsh modify sys db failover.selinuxallowscripts value enable

info "Disabling gui-setup"
tmsh modify sys global-settings gui-setup disabled

info "Saving config"
tmsh save /sys config

info "Initial networking configuration is complete"
exit 0
