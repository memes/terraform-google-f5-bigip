#!/bin/sh
# shellcheck disable=SC1091
#
# This script applies a CFE JSON declaration, if present in metadata, and will
# override the no-op customConfig.sh and be executed close to the end of setup.

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

cfe_payload="$(get_instance_attribute cfe_payload)"
if [ -z "${cfe_payload}" ]; then
    info "Cloud Failover Extension payload was not in metadata"
    exit 0
fi

ADMIN_PASSWORD="$(get_secret admin_password_key)"
[ -z "${ADMIN_PASSWORD}" ] && \
    error "Couldn't retrieve admin password from Secrets Manager"

retry=0
while [ ${retry} -lt 10 ]; do
    curl -skf --retry 20 -u "admin:${ADMIN_PASSWORD}" --max-time 60 \
        -H "Content-Type: application/json;charset=UTF-8" \
        -H "Origin: https://${MGMT_ADDRESS:-localhost}${MGMT_GUI_PORT:+":${MGMT_GUI_PORT}"}" \
        -o /dev/null \
        "https://${MGMT_ADDRESS:-localhost}${MGMT_GUI_PORT:+":${MGMT_GUI_PORT}"}/mgmt/shared/cloud-failover/info" && break
    info "Check for CFE installation failed, sleeping before retest: curl exit code $?"
    sleep 15
    retry=$((retry+1))
done
[ ${retry} -ge 10 ] && \
    error "Cloud Failover Extension is not installed"

# Extracting payload to file to avoid any escaping or interpolation issues
raw="$(mktemp -p /var/tmp)"
extract_payload "${cfe_payload}" > "${raw}" || \
    error "Unable to extract encoded payload: $?"
# Execute the raw JSON as a jq file; allows environment substitutions to embed
# Admin password, for example, at run-time.
payload="$(mktemp -p /var/tmp)"
jq --null-input --raw-output --from-file "${raw}" > "${payload}" || \
    error "Unable to process raw file as JSON: $?"
rm -f "${raw}" || info "Unable to delete ${raw}"

info "Applying CFE payload"
response="$(curl -sk -u "admin:${ADMIN_PASSWORD}" --max-time 60 \
    -H "Content-Type: application/json" \
    -H "Origin: https://${MGMT_ADDRESS:-localhost}${MGMT_GUI_PORT:+":${MGMT_GUI_PORT}"}" \
    -d @"${payload}" \
    -w '\n{"status": "%{http_code}"}' \
    "https://${MGMT_ADDRESS:-localhost}${MGMT_GUI_PORT:+":${MGMT_GUI_PORT}"}/mgmt/shared/cloud-failover/declare" | jq --raw-output --slurp-file add)" || \
error "Error applying CFE payload from ${payload}: curl exit code $?"
status="$(echo "${response}" | jq --raw-output .status)"
case "${status}" in
    200)
            info "CFE declaration is applied"
            ;;
    4*|5*)
            error "CFE payload failed to install with error(s): message is $(echo "${response}" | jq --raw-output '.message')"
            ;;
    *)
            info "CFE has status ${status}: ${response}"
            ;;
esac
rm -f "${payload}" || info "Unable to delete ${payload}"
