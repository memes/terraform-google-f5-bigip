# This jq filter file will find suitable replacement values for specific DO fields
# that have the value 'replace'. It expects to be invoked with a password argument,
# the output from network metadata query, and the DO file to update.
#
# E.g. curl ... 'http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/?recursive=true' | \
# jq --arg password "S3cretP@assword" \
#         --from-file /path/to/do_replace_filter.jq \
#         --slurp - /path/to/do.json

# Count the set bits in supplied integer
def bcount: [while(. > 0; . / 2 | floor) | . % 2] | add;

# Split netmask into octets and count the set bits to get CIDR length
def bits: split(".") | map(tonumber | bcount) | add;

# GCP always sets gateway as first address in network, so network is gw - 1
# Note: this will fail if gw has last octet as zero
def net: split(".") | map(tonumber) | .[3] |= . - 1 | map(tostring) | join(".");

.[0] as $net | .[1] |
# Update nic0 (external) interface from metadata where value is 'replace'
(if .Common.external.mtu == "replace" then .Common.external.mtu |= $net[0].mtu else . end) |
(if .Common."external-self".address == "replace" then .Common."external-self".address |= $net[0].ip + "/32" else . end) |
(if .Common."external-rt-gw".network == "replace" then .Common."external-rt-gw".network |= $net[0].gateway + "/32" else . end) |
(if .Common."external-rt-gw".mtu == "replace" then .Common."external-rt-gw".mtu |= $net[0].mtu else . end) |
(if .Common."external-rt-net".gw == "replace" then .Common."external-rt-net".gw |= $net[0].gateway else . end) |
(if .Common."external-rt-net".network == "replace" then .Common."external-rt-net".network |= ($net[0].gateway | net) + "/" + ($net[0].subnetmask | bits | tostring) else . end) |
(if .Common."external-rt-net".mtu == "replace" then .Common."external-rt-net".mtu |= $net[0].mtu else . end) |

# Update nic2 (internal) interface from metadata where value is 'replace' and if the VM has 3+ interfaces
(if $net[2] and .Common.internal.mtu == "replace" then .Common.internal.mtu |= $net[2].mtu else . end) |
(if $net[2] and .Common."internal-self".address == "replace" then .Common."internal-self".address |= $net[2].ip + "/32" else . end) |
(if $net[2] and .Common."internal-rt-gw".network == "replace" then .Common."internal-rt-gw".network |= $net[2].gateway + "/32" else . end) |
(if $net[2] and .Common."internal-rt-gw".mtu == "replace" then .Common."internal-rt-gw".mtu |= $net[2].mtu else . end) |
(if $net[2] and .Common."internal-rt-net".gw == "replace" then .Common."internal-rt-net".gw |= $net[2].gateway else . end) |
(if $net[2] and .Common."internal-rt-net".network == "replace" then .Common."internal-rt-net".network |= ($net[2].gateway | net) + "/" + ($net[2].subnetmask | bits | tostring) else . end) |
(if $net[2] and .Common."internal-rt-net".mtu == "replace" then .Common."internal-rt-net".mtu |= $net[2].mtu else . end) |

# Update nic3 (internal1) interface from metadata where value is 'replace' and if the VM has 4+ interfaces
(if $net[3] and .Common.internal1.mtu == "replace" then .Common.internal1.mtu |= $net[3].mtu else . end) |
(if $net[3] and .Common."internal1-self".address == "replace" then .Common."internal1-self".address |= $net[3].ip + "/32" else . end) |
(if $net[3] and .Common."internal1-rt-gw".network == "replace" then .Common."internal1-rt-gw".network |= $net[3].gateway + "/32" else . end) |
(if $net[3] and .Common."internal1-rt-gw".mtu == "replace" then .Common."internal1-rt-gw".mtu |= $net[3].mtu else . end) |
(if $net[3] and .Common."internal1-rt-net".gw == "replace" then .Common."internal1-rt-net".gw |= $net[3].gateway else . end) |
(if $net[3] and .Common."internal1-rt-net".network == "replace" then .Common."internal1-rt-net".network |= ($net[3].gateway | net) + "/" + ($net[3].subnetmask | bits | tostring) else . end) |
(if $net[3] and .Common."internal1-rt-net".mtu == "replace" then .Common."internal1-rt-net".mtu |= $net[3].mtu else . end) |

# Update nic4 (internal2) interface from metadata where value is 'replace' and if the VM has 5+ interfaces
(if $net[4] and .Common.internal2.mtu == "replace" then .Common.internal2.mtu |= $net[4].mtu else . end) |
(if $net[4] and .Common."internal2-self".address == "replace" then .Common."internal2-self".address |= $net[4].ip + "/32" else . end) |
(if $net[4] and .Common."internal2-rt-gw".network == "replace" then .Common."internal2-rt-gw".network |= $net[4].gateway + "/32" else . end) |
(if $net[4] and .Common."internal2-rt-gw".mtu == "replace" then .Common."internal2-rt-gw".mtu |= $net[4].mtu else . end) |
(if $net[4] and .Common."internal2-rt-net".gw == "replace" then .Common."internal2-rt-net".gw |= $net[4].gateway else . end) |
(if $net[4] and .Common."internal2-rt-net".network == "replace" then .Common."internal2-rt-net".network |= ($net[4].gateway | net) + "/" + ($net[4].subnetmask | bits | tostring) else . end) |
(if $net[4] and .Common."internal2-rt-net".mtu == "replace" then .Common."internal2-rt-net".mtu |= $net[4].mtu else . end) |

# Update nic5 (internal3) interface from metadata where value is 'replace' and if the VM has 6+ interfaces
(if $net[5] and .Common.internal3.mtu == "replace" then .Common.internal3.mtu |= $net[5].mtu else . end) |
(if $net[5] and .Common."internal3-self".address == "replace" then .Common."internal3-self".address |= $net[5].ip + "/32" else . end) |
(if $net[5] and .Common."internal3-rt-gw".network == "replace" then .Common."internal3-rt-gw".network |= $net[5].gateway + "/32" else . end) |
(if $net[5] and .Common."internal3-rt-gw".mtu == "replace" then .Common."internal3-rt-gw".mtu |= $net[5].mtu else . end) |
(if $net[5] and .Common."internal3-rt-net".gw == "replace" then .Common."internal3-rt-net".gw |= $net[5].gateway else . end) |
(if $net[5] and .Common."internal3-rt-net".network == "replace" then .Common."internal3-rt-net".network |= ($net[5].gateway | net) + "/" + ($net[5].subnetmask | bits | tostring) else . end) |
(if $net[5] and .Common."internal3-rt-net".mtu == "replace" then .Common."internal3-rt-net".mtu |= $net[5].mtu else . end) |

# Update nic6 (internal4) interface from metadata where value is 'replace' and if the VM has 7+ interfaces
(if $net[6] and .Common.internal4.mtu == "replace" then .Common.internal4.mtu |= $net[6].mtu else . end) |
(if $net[6] and .Common."internal4-self".address == "replace" then .Common."internal4-self".address |= $net[6].ip + "/32" else . end) |
(if $net[6] and .Common."internal4-rt-gw".network == "replace" then .Common."internal4-rt-gw".network |= $net[6].gateway + "/32" else . end) |
(if $net[6] and .Common."internal4-rt-gw".mtu == "replace" then .Common."internal4-rt-gw".mtu |= $net[6].mtu else . end) |
(if $net[6] and .Common."internal4-rt-net".gw == "replace" then .Common."internal4-rt-net".gw |= $net[6].gateway else . end) |
(if $net[6] and .Common."internal4-rt-net".network == "replace" then .Common."internal4-rt-net".network |= ($net[6].gateway | net) + "/" + ($net[6].subnetmask | bits | tostring) else . end) |
(if $net[6] and .Common."internal4-rt-net".mtu == "replace" then .Common."internal4-rt-net".mtu |= $net[6].mtu else . end) |

# Update nic7 (internal5) interface from metadata where value is 'replace' and if the VM has 8 interfaces
(if $net[7] and .Common.internal5.mtu == "replace" then .Common.internal5.mtu |= $net[7].mtu else . end) |
(if $net[7] and .Common."internal5-self".address == "replace" then .Common."internal5-self".address |= $net[7].ip + "/32" else . end) |
(if $net[7] and .Common."internal5-rt-gw".network == "replace" then .Common."internal5-rt-gw".network |= $net[7].gateway + "/32" else . end) |
(if $net[7] and .Common."internal5-rt-gw".mtu == "replace" then .Common."internal5-rt-gw".mtu |= $net[7].mtu else . end) |
(if $net[7] and .Common."internal5-rt-net".gw == "replace" then .Common."internal5-rt-net".gw |= $net[7].gateway else . end) |
(if $net[7] and .Common."internal5-rt-net".network == "replace" then .Common."internal5-rt-net".network |= ($net[7].gateway | net) + "/" + ($net[7].subnetmask | bits | tostring) else . end) |
(if $net[7] and .Common."internal5-rt-net".mtu == "replace" then .Common."internal5-rt-net".mtu |= $net[7].mtu else . end) |

# Update default gateway to nic0 (external) metadata where value is 'replace'
(if .Common.default.gw == "replace" then .Common.default.gw |= $net[0].gateway else . end) |
(if .Common.default.mtu == "replace" then .Common.default.mtu |= $net[0].mtu else . end) |

# Update device trust password, if needed
(if $password and .Common.trust.localPassword == "replace" then .Common.trust.localPassword |= $password else . end) |
(if $password and .Common.trust.remotePassword == "replace" then .Common.trust.remotePassword |= $password else . end)
