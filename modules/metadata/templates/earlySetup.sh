#!/bin/sh
# shellcheck disable=SC1091,SC2086,SC2154,SC2046
#
# This script will set BIG-IP parameters that are best set early in the onboarding
# process


if [ -f /config/cloud/gce/setupUtils.sh ]; then
    . /config/cloud/gce/setupUtils.sh
else
    echo "$${GCE_LOG_TS:+"$(date +%Y-%m-%dT%H:%M:%S.%03N%z): "}$0: ERROR: unable to source /config/cloud/gce/setupUtils.sh" >&2
    [ -e /dev/ttyS0 ] && \
        echo "$(date +%Y-%m-%dT%H:%M:%S.%03N%z): $0: ERROR: unable to source /config/cloud/gce/setupUtils.sh" >/dev/ttyS0
    exit 1
fi

info "Waiting for mcpd to be ready"
. /usr/lib/bigstart/bigip-ready-functions
wait_bigip_ready

info "Setting shared message size to ${max_msg_body_size}"
retry=0
# shellcheck disable=SC2170
while [ "$${retry}" -lt 10 ]; do
    # shellcheck disable=SC2016
    curl -sf --retry 20 -u "admin:" --max-time 60 \
        -H "Content-Type: application/json" \
        -d '{"maxMessageBodySize": ${jsonencode(max_msg_body_size)}}' \
        "http://localhost:8100/mgmt/shared/server/messaging/settings/8100" && break
    info "Setting shared message size failed, sleeping before retest: curl exit code $?"
    sleep 15
    retry=$((retry+1))
done
# shellcheck disable=SC2170
[ "$${retry}" -ge 10 ] && \
    info "Failed to set shared message size"

# Provision extra RAM
info "Provisioning ${extramb}MB of RAM"
/usr/bin/setdb provision.extramb ${extramb} || \
    info "Unable to provision extra RAM"
info "Allow restjavad to use extra RAM"
/usr/bin/setdb restjavad.useextramb true || \
    info "Unable to use extra RAM in restjavad"

info "Saving config"
tmsh save /sys config

info "Restarting REST daemons"
bigstart restart restjavad restnoded || \
    info "Error restarting REST daemons: $?"

exit 0
