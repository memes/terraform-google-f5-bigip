#!/bin/sh
#
# Reusable functions for the BIG-IP setup scripts

# Write an error message to stderr and serial console, then exit
error()
{
    echo "${GCE_LOG_TS:+"$(date +%Y-%m-%dT%H:%M:%S.%03N%z): "}$0: Error: $*" >&2
    if [ -e /dev/ttyS0 ]; then
        echo "$(date +%Y-%m-%dT%H:%M:%S.%03N%z): $0: Error: $*" >/dev/ttyS0
    fi
    # When some components fail to install, connectivity is limited. If
    # requested (metadata triggered) output some info to serial console.
    if [ -f /var/run/gce_setup_utils_details_on_error ] && [ -e /dev/ttyS0 ]; then
        echo "  kernel interfaces: " >/dev/ttyS0
        ip a s >/dev/ttyS0
        echo "  kernel routes:" > /dev/ttyS0
        ip r s >/dev/ttyS0
        echo "  TMOS interfaces:" >/dev/ttyS0
        tmsh list /net interface >/dev/ttyS0
        echo "  TMOS routes:" >/dev/ttyS0
        tmsh list /net route >/dev/ttyS0
        echo "  TMOS self:" >/dev/ttyS0
        tmsh list /net self >/dev/ttyS0
        echo "  TMOS vlans:" >/dev/ttyS0
        tmsh list /net vlan >/dev/ttyS0
        echo "  restnoded.log:" >/dev/ttyS0
        tail -500 /var/log/restnoded/restnoded.log > /dev/ttyS0
    fi
    exit 1
}

# Write an informational message to stderr and serial console
info()
{
    echo "${GCE_LOG_TS:+"$(date +%Y-%m-%dT%H:%M:%S.%03N%z): "}$0: Info: $*" >&2
    [ -e /dev/ttyS0 ] && \
        echo "$(date +%Y-%m-%dT%H:%M:%S.%03N%z): $0: Info: $*" >/dev/ttyS0
}

# Retrieves a value associated with the supplied key from the instance metadata
# $1 = attribute key to pull
# $2 = optional default value to return if $1 doesn't exist
get_instance_attribute()
{
    attempt=0
    while [ "${attempt:-0}" -lt 10 ]; do
        http_status=$(curl -so /dev/null -w '%{http_code}' -H 'Metadata-Flavor: Google' "http://169.254.169.254/computeMetadata/v1/instance/attributes/${1}")
        retval=$?
        if [ "${retval}" -eq 0 ]; then
            if [ "${http_status}" -eq 200 ]; then
                curl -s --retry 20 -H 'Metadata-Flavor: Google' "http://169.254.169.254/computeMetadata/v1/instance/attributes/${1}?alt=text"
            else
                echo "${2:-""}"
            fi
            break
        fi
        info "get_instance_attribute: ${attempt}: Curl failed for ${1} with exit code ${retval}; sleeping before retry"
        sleep 10
        attempt=$((attempt+1))
    done
    [ "${attempt}" -ge 10 ] && \
        info "get_instance_attribute: ${attempt}: Failed to get a result for ${1} from metadata server"
    return ${retval}
}

# Retrieves a value associated with the supplied key from the project metadata
# $1 = attribute key to pull
get_project_attribute()
{
    attempt=0
    while [ "${attempt:-0}" -lt 10 ]; do
        http_status=$(curl -so /dev/null -w '%{http_code}' -H 'Metadata-Flavor: Google' "http://169.254.169.254/computeMetadata/v1/project/${1}")
        retval=$?
        if [ "${retval}" -eq 0 ]; then
            if [ "${http_status}" -eq 200 ]; then
                curl -s --retry 20 -H 'Metadata-Flavor: Google' "http://169.254.169.254/computeMetadata/v1/project/${1}?alt=text"
            else
                echo ""
            fi
            break
        fi
        info "get_project_attribute: ${attempt}: Curl failed for ${1} with exit code ${retval}; sleeping before retry"
        sleep 10
        attempt=$((attempt+1))
    done
    [ "${attempt}" -ge 10 ] && \
        info "get_project_attribute: ${attempt}: Failed to get a result for ${1} from metadata server"
    return ${retval}
}

# Returns an OAuth token for active service account
get_auth_token()
{
    attempt=0
    while [ "${attempt:-0}" -lt 10 ]; do
        auth_token="$(curl -sf -H 'Metadata-Flavor: Google' 'http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token' | jq -r '.access_token')"
        retval=$?
        if [ "${retval}" -eq 0 ]; then
            echo "${auth_token}"
            break
        fi
        info "get_auth_token: ${attempt}: Curl failed with exit code $?; sleeping before retry"
        sleep 10
        attempt=$((attempt+1))
    done
    [ "${attempt}" -ge 10 ] && \
        info "get_auth_token: ${attempt}: Failed to get an auth token from metadata server"
    return ${retval}
}

# Return the contents of a secret from a secret implementor, using a metadata key
# as the indirection layer. E.g. get_secret "foo" will lookup the instance
# metadata value for "foo", and use that as the key for secret implementor value
# lookup.
#
# $1 = metadata attribute key that should hold the secret key to retrieve,
# defaults to 'admin_password_key'.
get_secret()
{
    secret_implementor="$(get_instance_attribute "secret_implementor" "google_secret_manager")"
    secret_key="$(get_instance_attribute "${1:-"admin_password_key"}")"
    if [ -n "${secret_key}" ]; then
        if eval "command -v get_secret_${secret_implementor} >/dev/null"; then
            info "get_secret: retrieving password using ${secret_implementor}"
            eval "get_secret_${secret_implementor} ${secret_key}"
        else
            info "get_secret: implementor ${secret_implementor} is undefined; sending an empty password to caller."
            echo ""
        fi
    else
        info "get_secret: secret key is empty; sending an empty password to caller."
        echo ""
    fi
    return 0
}

# Return the contents of a secret from GCP Secret Manager using the supplied key.
#
# $1 = project specific key of the secret manager value to lookup.
get_secret_google_secret_manager()
{
    auth_token="$(get_auth_token)" || error "get_secret_google_secret_manager: Unable to get auth token: $?"
    project_id="$(get_project_attribute project-id)" || \
        error "get_secret_google_secret_manager: Unable to get project id from metadata: Curl exit code $?"
    attempt=0
    while [ "${attempt:-0}" -lt 10 ]; do
        http_status=$(curl -so /dev/null -w '%{http_code}' -H "Authorization: Bearer ${auth_token}" "https://secretmanager.googleapis.com/v1/projects/${project_id}/secrets/${1}/versions/latest:access" 2>/dev/null)
        retval=$?
        if [ "${retval}" -eq 0 ]; then
            if [ "${http_status}" -eq 200 ]; then
                curl -s -H "Authorization: Bearer ${auth_token}" "https://secretmanager.googleapis.com/v1/projects/${project_id}/secrets/${1}/versions/latest:access" 2>/dev/null | \
                    jq -r '.payload.data' 2>/dev/null | base64 -d 2>/dev/null
            else
                echo ""
            fi
            break
        fi
        info "get_secret_google_secret_manager: ${attempt}: Curl failed to get secret from Secret Manager: exit code: ${retval}; sleeping before retry"
        sleep 10
        attempt=$((attempt+1))
    done
    [ "${attempt}" -ge 10 ] && \
        info "get_secret_google_secret_manager: ${attempt}: Failed to get a secret from Secret Manager"

    return 0
}

# Return the contents of a secret from metadata attribute. This is NOT secure.
#
# $1 = metadata key to lookup for secret value.
get_secret_metadata()
{
    get_instance_attribute "${1}"
    return 0
}

# Extract the contents of the supplied value and write to stdout
# $1 = payload contents must be a URL or base64 encoded and gzipped string
extract_payload()
{
    [ -n "${1}" ] || \
        error "payload content is required"
    case "${1}" in
        https://storage.googleapis.com/*)
            auth_token="$(get_auth_token)" || \
                error "extract_payload: Unable to get auth token: $?"
            curl -sf --retry 20 \
                    -H "Authorization: Bearer ${auth_token}" \
                    "${1}" || \
                error "extract_payload: Download of GCS file from ${1} failed: $?"
            ;;
        ftp://*|http://*|https://*)
            curl -skf --retry 20 "${1}" || \
                error "extract_payload: Download of ${1} failed with exit code $?"
            ;;
        *)
            base64 -d <<EOF | zcat || error "extract_payload: Unable to decode payload: $?"
${1}
EOF
            ;;
    esac
    return 0
}
