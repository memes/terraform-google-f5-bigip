#!/bin/sh
# shellcheck disable=SC2154
#
# This script will install the supporting files necessary to initialise a BIG-IP
# instance on GCP.

error()
{
    echo "$(date +%Y-%m-%dT%H:%M:%S.%03N%z): $0: Error: $*" >&2
    [ -e /dev/ttyS0 ] && \
        echo "$(date +%Y-%m-%dT%H:%M:%S.%03N%z): $0: Error: $*" >&2
    exit 1
}

info()
{
    echo "$(date +%Y-%m-%dT%H:%M:%S.%03N%z): $0: Info: $*" >&2
    [ -e /dev/ttyS0 ] && \
        echo "$(date +%Y-%m-%dT%H:%M:%S.%03N%z): $0: Info: $*" >&2
}

mkdir -p /config/cloud/gce /var/log/cloud/google

if [ ! -f /config/cloud/gce/setupUtils.sh ]; then
    base64 -d <<EOF | zcat > /config/cloud/gce/setupUtils.sh
${setup_utils_sh}
EOF
    chmod 0755 /config/cloud/gce/setupUtils.sh
fi
if [ ! -f /config/cloud/gce/multiNicMgmtSwap.sh ]; then
    base64 -d <<EOF | zcat > /config/cloud/gce/multiNicMgmtSwap.sh
${multi_nic_mgt_swap_sh}
EOF
    chmod 0755 /config/cloud/gce/multiNicMgmtSwap.sh
fi
if [ ! -f /config/cloud/gce/initialNetworking.sh ]; then
    base64 -d <<EOF | zcat > /config/cloud/gce/initialNetworking.sh
${initial_networking_sh}
EOF
    chmod 0755 /config/cloud/gce/initialNetworking.sh
fi
if [ ! -f /config/cloud/verifyHash ]; then
    base64 -d <<EOF | zcat > /config/cloud/verifyHash
${verify_hash_tcl}
EOF
    chmod 0644 /config/cloud/verifyHash
fi
if [ ! -f /config/cloud/gce/installCloudLibs.sh ]; then
    base64 -d <<EOF | zcat > /config/cloud/gce/installCloudLibs.sh
${install_cloud_libs_sh}
EOF
    chmod 0755 /config/cloud/gce/installCloudLibs.sh
fi
if [ ! -f /config/cloud/gce/resetManagementRoute.sh ]; then
    base64 -d <<EOF | zcat > /config/cloud/gce/resetManagementRoute.sh
${reset_management_route_sh}
EOF
    chmod 0755 /config/cloud/gce/resetManagementRoute.sh
fi
if [ ! -f /config/cloud/gce/initialSetup.sh ]; then
    base64 -d <<EOF | zcat > /config/cloud/gce/initialSetup.sh
${initial_setup_sh}
EOF
    chmod 0755 /config/cloud/gce/initialSetup.sh
fi
if [ ! -f /config/cloud/gce/applicationServices3.sh ]; then
   base64 -d <<EOF | zcat > /config/cloud/gce/applicationServices3.sh
${application_services3_sh}
EOF
    chmod 0755 /config/cloud/gce/applicationServices3.sh
fi
if [ ! -f /config/cloud/gce/declarativeOnboarding.sh ]; then
   base64 -d <<EOF | zcat > /config/cloud/gce/declarativeOnboarding.sh
${declarative_onboarding_sh}
EOF
    chmod 0755 /config/cloud/gce/declarativeOnboarding.sh
fi
if [ ! -f /config/cloud/gce/customConfig.sh ]; then
   base64 -d <<EOF | zcat > /config/cloud/gce/customConfig.sh
${custom_config_sh}
EOF
    chmod 0755 /config/cloud/gce/customConfig.sh
fi
if [ ! -f /config/cloud/gce/do_filter.jq ]; then
    base64 -d <<EOF | zcat > /config/cloud/gce/do_filter.jq
${do_filter_jq}
EOF
    chmod 0644 /config/cloud/gce/do_filter.jq
fi

[ -x /config/cloud/gce/initialSetup.sh ] || \
    error "/config/cloud/gce/initialSetup.sh is missing"
info "Launching scripts in background"
nohup /bin/sh -c 'export GCE_LOG_TS=1; /config/cloud/gce/initialSetup.sh && /config/cloud/gce/resetManagementRoute.sh' </dev/null &>>/var/log/cloud/google/startup-script.log &
