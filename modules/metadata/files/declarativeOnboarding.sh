#!/bin/sh
# shellcheck disable=SC1091
#
# This file will apply a Declarative Onboarding JSON file pulled from metadata,
# if the DO extension is installed and a DO file is in metadata.

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
    info "Declarative Onboarding payload was not supplied"
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
        "https://${MGMT_ADDRESS:-localhost}${MGMT_GUI_PORT:+":${MGMT_GUI_PORT}"}/mgmt/shared/declarative-onboarding/info" && break
    info "Check for DO installation failed, sleeping before retest: curl exit code $?"
    sleep 15
    retry=$((retry+1))
done
[ ${retry} -ge 10 ] && \
    error "Declarative Onboarding extension is not installed"

# Extracting payload to file to avoid any escaping or interpolation issues
raw="$(mktemp -p /var/tmp)"
extract_payload "${1}" > "${raw}" || \
    error "Unable to extract encoded payload: $?"

if [ -f /config/cloud/gce/do_filter.jq ]; then
    # Execute the raw JSON through a jq filter; allows run-time substitutions to
    # update ip addresses, MTUs, admin passwords, etc.
    payload="$(mktemp -p /var/tmp)"
    curl -sf --retry 20  -H 'Metadata-Flavor: Google' \
            'http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/?recursive=true' | \
        jq --arg password "${ADMIN_PASSWORD}" \
            --from-file /config/cloud/gce/do_filter.jq \
            --slurp - "${raw}" > "${payload}" || \
        error "Unable to process raw DO file ${raw} through jq: $?"
    rm -f "${raw}" || info "Unable to delete ${raw}"
else
    payload="${raw}"
fi

attempt=0
response="$(mktemp -p /var/tmp)"
while [ "${attempt:-0}" -lt 10 ]; do
    info "${attempt}: Applying Declarative Onboarding payload from ${payload}"
    # Issue #79 - adding a charset to Content-Type when POSTing results in 400 response
    # https://github.com/F5Networks/f5-declarative-onboarding/issues/79
    status="$(curl -sk -u "admin:${ADMIN_PASSWORD}" --max-time 60 \
        -H "Content-Type: application/json" \
        -H "Origin: https://${MGMT_ADDRESS:-localhost}${MGMT_GUI_PORT:+":${MGMT_GUI_PORT}"}" \
        -d @"${payload}" \
        -o "${response}" \
        -w '{"http_status": "%{http_code}"}' \
        "https://${MGMT_ADDRESS:-localhost}${MGMT_GUI_PORT:+":${MGMT_GUI_PORT}"}/mgmt/shared/declarative-onboarding" | jq --raw-output '.http_status')"
    retVal=$?
    id="$(jq --raw-output '.id' < "${response}")"
    case "${status}" in
        2*)
            info "${attempt}: Declarative Onboarding applied from ${payload} with ID ${id}"
            break
            ;;
        4*)
            error "${attempt}: POSTing of Declarative Onboarding failed: ${status}: response captured in ${response}"
            ;;
        *)
            info "${attempt}: POSTing of Declarative Onboarding failed: ${status}: response captured in ${response}; sleeping before retry"
            ;;
    esac
    sleep 15
    attempt=$((attempt+1))
done
[ "${attempt}" -ge 10 ] && \
    error "${attempt}: Error applying Declarative Onboarding payload from ${payload}, with response in ${response}: curl exit code ${retVal}"

while true; do
    curl -sk -u "admin:${ADMIN_PASSWORD}" --max-time 60 \
            -H "Content-Type: application/json;charset=UTF-8" \
            -H "Origin: https://${MGMT_ADDRESS:-localhost}${MGMT_GUI_PORT:+":${MGMT_GUI_PORT}"}" \
            -o "${response}" \
            "https://${MGMT_ADDRESS:-localhost}${MGMT_GUI_PORT:+":${MGMT_GUI_PORT}"}/mgmt/shared/declarative-onboarding/task/${id}" || \
        error "Failed to get status for task ${id}: curl exit code: $?"
    code="$(jq --raw-output 'if .result then .result.code else .code end' < "${response}")"
    # Response is often truncated on error and JQ on BIG-IP silently fails if the
    # input is an invalid JSON; grep for a code and use that as fallback
    [ -z "${code}" ] && \
        code="$(grep -o '"code":[0-9]*' "${response}" | cut -d: -f2)"
    case "${code}" in
        200)
                info "Declarative Onboarding is complete"
                break
                ;;
        202)
                info "Declarative Onboarding is in process"
                ;;
        4*|5*)
                error "Declarative Onboarding payload failed to install with error(s): (partial) response is in ${response}"
                ;;
        *)
                info "Declarative Onboarding has code ${code}"
                ;;
    esac
    info "Sleeping before rechecking Declarative Onboarding tasks"
    sleep 15
done
rm -f "${payload}" || info "Unable to delete ${payload}"
rm -f "${response}" || info "Unable to delete ${response}"
exit 0
