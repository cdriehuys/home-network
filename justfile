# Show available recipes
default:
    @just --list

# Create template for Proxmox VMs using Packer
[group('metal')]
create-vm-template:
    packer init ./metal/packer
    packer build ./metal/packer

# All bare metal configuration steps
[group('metal')]
metal: metal-provision metal-configure

# Provision Proxmox VMs
[group('metal')]
metal-provision:
    #!/usr/bin/env bash
    pushd ./metal
    terraform init
    terraform apply

# Configure VMs using Ansible
[group('metal')]
metal-configure: && metal-fetch-kubeconfig
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

# Fetch the Kubernetes config file
[group('metal')]
metal-fetch-kubeconfig:
    #!/usr/bin/env bash
    set -euf

    auth_check="$(kubectl auth can-i get pods)"
    if [[ "${auth_check}" = "yes" ]]; then
        echo "Valid Kubernetes config already present"
        exit 0
    fi

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
        download-kubeconfig.yml


# SSH into a VM by name
[group('metal')]
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
    ip="$(echo "${vms}" | jq -r '.["{{ vm }}"]')"

    if [[ "${ip}" = "null" ]]; then
        echo "No VM named {{ vm }} in ${vms}"
        exit 1
    fi

    echo "Connecting to {{ vm }} through ${ip}"
    ssh -i "${key_file}" -o StrictHostKeyChecking=no "provisioning@${ip}"

# Output the public key used for provisioning
[group('metal')]
give-me-the-public-key:
    #!/usr/bin/env bash
    pushd ./metal > /dev/null
    terraform output -raw provisioning_key_public

# Output the private key used for provisioning
[group('metal')]
give-me-the-private-key:
    #!/usr/bin/env bash
    pushd ./metal > /dev/null
    terraform output -raw provisioning_key_private

# Provision the platform used to run applications
[group('platform')]
platform: metal-fetch-kubeconfig
    #!/usr/bin/env bash
    pushd ./platform
    terraform init
    terraform apply

# Reset the initial Argo CD password
[group('platform')]
reset-initial-argocd-password: metal-fetch-kubeconfig
    #!/usr/bin/env bash
    set -euf

    export ARGOCD_SERVER=argocd.proxy2.lan.qidux.com:443
    initial_password="$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"
    argocd account update-password \
        --account admin \
        --current-password "${initial_password}" \
        --grpc-web

    # If the above completed successfully, we can delete the secret.
    kubectl -n argocd delete secret argocd-initial-admin-secret

# Configure the applications running on the platform
[group('apps')]
apps:
    #!/usr/bin/env bash
    pushd ./apps
    terraform init
    terraform apply
