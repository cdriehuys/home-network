#!/bin/sh

# Fetches a list of advertisement hosts and transforms them into a configuration
# file for unbound to block those sites.

set -euf

block_list="$(mktemp --tmpdir=/tmp ad-hosts.XXXXXX)"

echo "server:"
wget --output-document - --quiet https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts \
    | grep '^0\.0\.0\.0' \
    | awk '{print "  local-zone: \""$2"\" redirect\n  local-data: \""$2" A 0.0.0.0\""}'

rm "${block_list}" 1>&2
