#!/bin/sh
#
# This is a no-operation shutdown script; replace it as needed for actions
# to take on shutdown of BIG-IP VM. The script must complete within 90s.
echo "$0: Shutdown" >&2
[ -e /dev/ttyS0 ] && echo "$0: Shutdown" >/dev/ttyS0
