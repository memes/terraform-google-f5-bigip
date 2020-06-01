#!/bin/sh
# shellcheck disable=SC1091
#
# This script will update TMM to switch to $1 as management interface, provided
# there are more than 1 nics defined, and current management nic is different.
#
# If $1 is empty, script will fallback to assuming eth1 as the assumptive target
# interface.
#
# Note: this script is not guarded by sentinel files - intent is to be
# idempotent but responsive to deliberate changes.

[ -f /config/cloud/gce/network.config ] && \
    . /config/cloud/gce/network.config

if [ "${NIC_COUNT:-0}" -gt 1 ] && [ "$(tmsh list sys db provision.managementeth value 2>/dev/null | awk -F\" 'NR==2 {print $2}')" != "${1:-eth1}" ]; then
    bigstart stop tmm
    tmsh modify sys db provision.managementeth value "${1:-eth1}"
    tmsh modify sys db provision.1nicautoconfig value disable
    tmsh save sys config
    [ -f /etc/ts/common/image.cfg ] && \
        sed -i "s/iface=eth0/iface=${1:-eth1}/g" /etc/ts/common/image.cfg
    echo "${GCE_LOG_TS:+"$(date +%Y-%m-%dT%H:%M:%S.%03N%z): "}$0: Rebooting for multi-nic management interface swap" >&2
    reboot
    # Reboot may be delayed; signal to caller that processing should stop
    exit 1
else
    echo "${GCE_LOG_TS:+"$(date +%Y-%m-%dT%H:%M:%S.%03N%z): "}$0: Nothing to do" >&2
fi
exit 0
