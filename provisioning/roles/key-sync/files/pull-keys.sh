#!/bin/sh

set -euf

authorized_keys_file="${HOME}/.ssh/authorized_keys"

keys_url="$1"
echo "Pulling keys from: ${keys_url}"

temp_keys="$(mktemp /tmp/authorized_keys.XXXXXX)"
echo "Will store keys in: ${temp_keys}"

curl --show-error --silent --fail --output "${temp_keys}" "${keys_url}"
echo "Downloaded keys"

echo "Key Info:"
ssh-keygen -lf "${temp_keys}"

chmod 644 "${temp_keys}"
mv "${temp_keys}" "${authorized_keys_file}"
echo "Updated '${authorized_keys_file}'"
