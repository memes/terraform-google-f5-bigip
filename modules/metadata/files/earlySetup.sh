#!/bin/sh
# shellcheck disable=SC1091
#
# This script will set BIG-IP parameters that are best set early in the onboarding
# process


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

# Provision extra RAM
info "Provisioning 1000mb of extra RAM"
/usr/bin/setdb provision.extramb 1000 || \
    info "Unable to provision extra RAM"
info "Allow restjavad to use extra RAM"
/usr/bin/setdb restjavad.useextramb true || \
    info "Unable to use extra RAM in restjavad"

exit 0
