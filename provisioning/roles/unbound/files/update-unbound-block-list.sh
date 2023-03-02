#!/bin/sh

set -euf

target_file="$1"

temp_list="$(mktemp --tmpdir=/tmp block-list.conf.XXXXX)"
echo "Generating block list to ${temp_list}..."

fetch-hosts-file-as-unbound-config.sh > "${temp_list}"

echo "Done."
echo

echo "Updating ${target_file}..."
chown unbound:unbound "${temp_list}"
mv "${temp_list}" "${target_file}"
echo "Done."
echo

echo "Reloading unbound..."
unbound-control reload
echo "Done."
echo
