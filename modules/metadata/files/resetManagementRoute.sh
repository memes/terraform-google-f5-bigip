#!/bin/sh
# shellcheck disable=SC1091
#
# This script is intended to be executed on every boot to ensure the management
# default gateway is set correctly. See also `f5-gce-management-route.service`
# unit on instance.
#
# https://support.f5.com/csp/article/K85730674

echo "${GCE_LOG_TS:+"$(date +%Y-%m-%dT%H:%M:%S.%03N%z): "}$0: waiting for mcpd to be ready" >&2
[ -e /dev/ttyS0 ] && \
    echo "$(date +%Y-%m-%dT%H:%M:%S.%03N%z): $0: waiting for mcpd to be ready" >/dev/ttyS0

. /usr/lib/bigstart/bigip-ready-functions
wait_bigip_ready

[ -f /config/cloud/gce/network.config ] && \
    . /config/cloud/gce/network.config

if [ "${NIC_COUNT:-0}" -gt 1 ] && [ -n "${MGMT_GATEWAY}" ]; then
    default_gw="$(tmsh list sys management-route default gateway | awk 'NR==2 { print $2 }')"
    while [ "${default_gw}" != "${MGMT_GATEWAY}" ]; do
        echo "$0: updating management default gateway to ${MGMT_GATEWAY}" >&2
        [ -e /dev/ttyS0 ] && \
            echo "$(date +%Y-%m-%dT%H:%M:%S.%03N%z): $0: updating management default gateway to ${MGMT_GATEWAY}" >/dev/ttyS0
        tmsh delete sys management-route default
        tmsh create sys management-route default gateway "${MGMT_GATEWAY}" mtu "${MGMT_MTU:-1460}"
        tmsh save sys config
        default_gw="$(tmsh list sys management-route default gateway | awk 'NR==2 { print $2 }')"
    done
fi
echo "${GCE_LOG_TS:+"$(date +%Y-%m-%dT%H:%M:%S.%03N%z): "}$0: complete" >&2
[ -e /dev/ttyS0 ] && \
    echo "$(date +%Y-%m-%dT%H:%M:%S.%03N%z): $0: complete" >/dev/ttyS0
