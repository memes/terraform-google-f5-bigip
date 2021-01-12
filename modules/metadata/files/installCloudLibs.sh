#!/bin/sh
# shellcheck disable=SC1091
#
# Install tarballs and RPMs from a list of URL arguments.
# E.g. installCloudLibs "URL" ... "URL"
#set -e

if [ -f /config/cloud/gce/setupUtils.sh ]; then
    . /config/cloud/gce/setupUtils.sh
else
    echo "${GCE_LOG_TS:+"$(date +%Y-%m-%dT%H:%M:%S.%03N%z): "}$0: ERROR: unable to source /config/cloud/gce/setupUtils.sh" >&2
    [ -e /dev/ttyS0 ] && \
        echo "$(date +%Y-%m-%dT%H:%M:%S.%03N%z): $0: ERROR: unable to source /config/cloud/gce/setupUtils.sh" >/dev/ttyS0
    exit 1
fi

if [ $# -lt 1 ]; then
    info "No libraries to install; exiting"
    return 0
fi

[ -f /config/cloud/gce/network.config ] && . /config/cloud/gce/network.config

# Download attempt can fail, especially after reseting network parameters on a
# 'small' instance, so retry up to 10 times.
retry_download() {
    # shellcheck disable=SC2039
    local url="$1"
    # shellcheck disable=SC2039
    local out="$2"
    shift
    shift
    attempt=0
    while [ "${attempt:-0}" -lt 10 ]; do
        info "retry_download: ${attempt}: Downloading ${url} to ${out}"
        curl -sfL --retry 20 -o "${out}" "$@" "${url}"
        retval=$?
        [ "${retval}" -eq 0 ] && break
        info "retry_download: ${attempt}: Failed to download from ${url}: exit code: $?; sleeping before retry"
        sleep 10
        attempt=$((attempt+1))
    done
    [ "${attempt}" -ge 10 ] && \
        error "retry_download: ${attempt}: Failed to download from ${url}; giving up"
    return 0
}

# Install RPM with retry logic where appropriate
retry_install()
{
    attempt=0
    while [ "${attempt:-0}" -lt 10 ]; do
        info "retry_install: ${attempt}: Installing ${out}"
        response="$(curl -skf --retry 20 -u "admin:${ADMIN_PASSWORD}" \
            -H "Content-Type: application/json;charset=UTF-8" \
            -H "Origin: https://${MGMT_ADDRESS:-localhost}${MGMT_GUI_PORT:+":${MGMT_GUI_PORT}"}" \
            --data "{\"operation\":\"INSTALL\",\"packageFilePath\":\"${out}\"}" \
            -w '\n{"http_status": "%{http_code}"}' \
            "https://${MGMT_ADDRESS:-localhost}${MGMT_GUI_PORT:+":${MGMT_GUI_PORT}"}/mgmt/shared/iapp/package-management-tasks" | jq -rs add)"
        retVal=$?
        status="$(echo "${response}" | jq -r .http_status)"
        case "${status}" in
            2*)
                info "retry_install: ${attempt}: ${out} is installed ${status}"
                echo "${response}" | jq -r '.id'
                return 0
                ;;
            4*|5*)
                error "retry_install: ${attempt}: failed to install ${out} returned status: ${status}: ${response}"
                return ${retVal}
                ;;
            *)
                info "retry_install: ${attempt}: installing ${out} returned status ${status}: ${response}; sleeping before retry"
                ;;
        esac
        sleep 10
        attempt=$((attempt+1))
    done
    [ "${attempt}" -ge 10 ] && \
        error "retry_install: ${attempt}: Failed to install ${out}; giving up"
    return ${retVal}
}

mkdir -p /config/cloud/gce/node_modules/@f5devcentral

info "waiting for mcpd"
. /usr/lib/bigstart/bigip-ready-functions
wait_bigip_ready

info "Getting admin password"
ADMIN_PASSWORD="$(get_secret admin_password_key)"

info "loading verifyHash script"
if ! tmsh load sys config merge file /config/cloud/verifyHash; then
    error "cannot validate signature of /config/cloud/verifyHash"
fi
info "loaded verifyHash"

# Due to asynchronous nature of installing RPMs, keep a list of in-progress tasks
# and files to delete
to_delete=""
task_ids=""
for url in "$@"; do
    case "${url}" in
        https://storage.googleapis.com/*)
            auth_token="$(get_auth_token)" || \
                error "Unable to get auth token: $?"
            out="/var/config/rest/downloads/$(basename "${url%%?alt=media}")"
            retry_download "${url}" "${out}" -H "Authorization: Bearer ${auth_token}"
            ;;
        ftp://*|http://*|https://*)
            out="/var/config/rest/downloads/$(basename "${url}")"
            retry_download "${url}" "${out}"
            ;;
        /*)
            out="${url}"
            ;;
        *)
            info "Don't recognise schema for ${url}"
            out=""
            ;;
    esac
    if [ -n "${out}" ]; then
        file="$(basename "${out}")"
        # Only try to verify the hash for known files
        if grep -q "${file}" /config/cloud/verifyHash; then
            info "Verifying ${file}"
            tmsh run cli script verifyHash "${out}" || \
                error "${out} failed validation"
            info verified "${out}"
        else
            info "Don't have a verification hash for ${file}"
        fi
        case "${out}" in
            *.tar.gz)
                info "Expanding ${out}"
                tar xzf "${out}" -C /config/cloud/gce/node_modules/@f5devcentral || \
                    error "tarball expansion failed with exit code: $?"
                to_delete="${to_delete}${to_delete:+" "}'${out}'"
                ;;
            *.rpm)
                if [ -n "${ADMIN_PASSWORD}" ]; then
                    id="$(retry_install "${out}")" || \
                        error "Failed to install ${out} with exit code: $?"
                    task_ids="${task_ids}${task_ids:+" "}${id}"
                    to_delete="${to_delete}${to_delete:+" "}'${out}'"
                else
                    info "Admin password is unknown, skipping installation of ${out}"
                fi
                ;;
            *)
                info "Skipping install of ${out}"
                ;;
        esac
    fi
done

# Wait until all application packages have been installed, or failed
errors=""
while [ -n "${task_ids}" ]; do
    pending_ids=""
    for id in ${task_ids}; do
        response="$(curl -skf --retry 20 -u "admin:${ADMIN_PASSWORD}" \
                    -H "Content-Type: application/json;charset=UTF-8" \
                    -H "Origin: https://${MGMT_ADDRESS:-localhost}${MGMT_GUI_PORT:+":${MGMT_GUI_PORT}"}" \
                    "https://${MGMT_ADDRESS:-localhost}${MGMT_GUI_PORT:+":${MGMT_GUI_PORT}"}/mgmt/shared/iapp/package-management-tasks/${id}")" || \
            error "Failed to get status for task ${id} with exit code: $?"
        status="$(echo "${response}" | jq -r '.status')"
        package="$(echo "${response}" | jq -r '.packageName')"
        case "${status}" in
            FINISHED)
                    info "Package ${package} is installed"
                    ;;
            FAILED)
                    msg="$(echo "${response}" | jq -r '.errorMessage')"
                    case "${msg}" in
                        *already*)
                            info "Package ${package} is already installed"
                            ;;
                        *)
                            info "Package ${package} failed to install with error: ${msg}"
                            errors="${errors}{id}"
                            ;;
                    esac
                    ;;
            *)
                    info "Package ${package} has status ${status}"
                    pending_ids="${pending_ids}${pending_ids:+" "}${id}"
                    ;;
        esac
    done
    [ -z "${pending_ids}" ] && break
    task_ids="${pending_ids}"
    info "Sleeping before reexamining installation tasks"
    sleep 5
done
[ -n "${errors}" ] && error "Failed to install some tasks, exiting script"

# Delete any obsolete files
for file in ${to_delete}; do
    info "Deleting ${file}"
    [ -f "${file}" ] && rm -f "${file}"
    [ -f "${file}" ] && info "Unable to delete ${file}, but continuing"
done

info "Cloud libraries are installed"
exit 0
