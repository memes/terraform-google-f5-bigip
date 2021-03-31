#!/bin/sh
# shellcheck disable=SC1091
#
# This file will apply an Application Services3 JSON file pulled from metadata,
# if the AS3 extension is installed and a AS3 file is in metadata.

if [ -f /config/cloud/gce/setupUtils.sh ]; then
    . /config/cloud/gce/setupUtils.sh
else
    echo "${GCE_LOG_TS:+"$(date +%Y-%m-%dT%H:%M:%S.%03N%z): "}$0: ERROR: unable to source /config/cloud/gce/setupUtils.sh" >&2
    [ -e /dev/ttyS0 ] && \
        echo "$(date +%Y-%m-%dT%H:%M:%S.%03N%z): $0: ERROR: unable to source /config/cloud/gce/setupUtils.sh" >/dev/ttyS0
    exit 1
fi

[ -f /config/cloud/gce/network.config ] && . /config/cloud/gce/network.config

if [ -z "${1}" ]; then
    info "AS3 payload was not supplied"
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
        "https://${MGMT_ADDRESS:-localhost}${MGMT_GUI_PORT:+":${MGMT_GUI_PORT}"}/mgmt/shared/appsvcs/info" && break
    info "Check for AS3 installation failed, sleeping before retest: curl exit code $?"
    sleep 5
    retry=$((retry+1))
done
[ ${retry} -ge 10 ] && \
    error "AS3 extension is not installed"

# Extracting payload to file to avoid any escaping or interpolation issues
raw="$(mktemp -p /var/tmp)"
extract_payload "${1}" > "${raw}" || \
    error "Unable to extract encoded payload: $?"
# Execute the raw JSON as a jq file; allows environment substitutions to embed
# Admin password, for example, at run-time. NOTE: for future use.
payload="$(mktemp -p /var/tmp)"
jq --null-input --raw-output --from-file "${raw}" > "${payload}" || \
    error "Unable to process raw file as JSON: $?"
rm -f "${raw}" || info "Unable to delete ${raw}"

info "Applying AS3 payload from ${payload}"
response="$(curl -sk -u "admin:${ADMIN_PASSWORD}" --max-time 60 \
        -H "Content-Type: application/json;charset=UTF-8" \
        -H "Origin: https://${MGMT_ADDRESS:-localhost}${MGMT_GUI_PORT:+":${MGMT_GUI_PORT}"}" \
        -d @"${payload}" \
        "https://${MGMT_ADDRESS:-localhost}${MGMT_GUI_PORT:+":${MGMT_GUI_PORT}"}/mgmt/shared/appsvcs/declare?async=true")" || \
    error "Error applying AS3 payload from ${payload}"
id="$(echo "${response}" | jq --raw-output '.id // ""')"
[ -n "${id}" ] || \
    error "Unable to submit AS3 declaration: $(echo "${response}" | jq --raw-output '.code + " " + .message')"

while true; do
    response="$(curl -sk -u "admin:${ADMIN_PASSWORD}" --max-time 60 \
                -H "Content-Type: application/json;charset=UTF-8" \
                -H "Origin: https://${MGMT_ADDRESS:-localhost}${MGMT_GUI_PORT:+":${MGMT_GUI_PORT}"}" \
                "https://${MGMT_ADDRESS:-localhost}${MGMT_GUI_PORT:+":${MGMT_GUI_PORT}"}/mgmt/shared/appsvcs/task/${id}")" || \
        error "Failed to get status for task ${id}: curl exit code: $?"
    code="$(echo "${response}" | jq --raw-output '.results[0].code // "unspecified"')"
    case "${code}" in
        0)
                info "AS3 payload is being processed"
                ;;
        200)
                info "AS3 payload is installed"
                break
                ;;
        4*|5*)
                error "AS3 payload failed to install with error(s): $(echo "${response}" | jq --raw-output '.results[0].message + " " + (.results[0].errors // [] | tostring)')"
                break
                ;;
        *)
                info "AS3 has code ${code}: ${response}"
                ;;
    esac
    info "Sleeping before rechecking AS3 tasks"
    sleep 5
done
rm -f "${payload}" || info "Unable to delete ${payload}"
exit 0
