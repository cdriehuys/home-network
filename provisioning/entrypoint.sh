#!/bin/bash

set -euf
set -o pipefail

ansible-playbook \
    -i ./inventory.yml \
    $@
