#!/bin/sh
# shellcheck disable=SC1091
#
# This script applies a nearly empty custom configuration. The script, or a
# customer supplied alternative, will be executed as the final setup/onboarding
# step of BIG-IP.

set -e

if [ -f /config/cloud/gce/setupUtils.sh ]; then
    . /config/cloud/gce/setupUtils.sh
else
    echo "${GCE_LOG_TS:+"$(date +%Y-%m-%dT%H:%M:%S.%03N%z): "}$0: ERROR: unable to source /config/cloud/gce/setupUtils.sh" >&2
    [ -e /dev/ttyS0 ] && \
        echo "$(date +%Y-%m-%dT%H:%M:%S.%03N%z): $0: ERROR: unable to source /config/cloud/gce/setupUtils.sh" >/dev/ttyS0
    exit 1
fi

info "waiting for mcpd to be ready"
. /usr/lib/bigstart/bigip-ready-functions
wait_bigip_ready

[ -f /config/cloud/gce/network.config ] && . /config/cloud/gce/network.config

# Custom steps should be added here, but use of Declarative Onboarding and AS3
# are a preferred solution to custom scripting.

info "Custom configuration is complete"
