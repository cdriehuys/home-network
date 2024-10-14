# Show available recipes
default:
    @just --list

# Create template for Proxmox VMs using Packer
create-vm-template:
    packer init ./metal/packer
    packer build ./metal/packer

# Provision Proxmox VMs
metal:
    #!/usr/bin/env bash
    pushd ./metal
    terraform init
    terraform plan | "${PAGER}"
    terraform apply

# Configure VMs using Ansible
metal-configure:
    #!/usr/bin/env bash
    key_file="$(mktemp)"
    function cleanup {
        echo "Removing key file ${key_file}"
        rm "${key_file}"
    }
    trap 'cleanup' EXIT

    pushd ./metal
    terraform output -raw provisioning_key_private > "${key_file}"

    ansible-playbook \
        --private-key "${key_file}" \
        --inventory ./inventory \
        site.yml

# SSH into a VM by name
ssh vm:
    #!/usr/bin/env bash
    key_file="$(mktemp)"
    function cleanup {
        echo "Removing key file ${key_file}"
        rm "${key_file}"
    }
    trap 'cleanup' EXIT

    pushd ./metal
    terraform output -raw provisioning_key_private > "${key_file}"
    chmod 600 "${key_file}"

    vms="$(terraform output -json vms)"
    ip="$(echo "${vms}" | jq -r 'fromjson | .["{{ vm }}"]')"

    if [[ "${ip}" = "null" ]]; then
        echo "No VM named {{ vm }} in ${vms}"
        exit 1
    fi

    echo "Connecting to {{ vm }} through ${ip}"
    ssh -i "${key_file}" -o StrictHostKeyChecking=no "provisioning@${ip}"
