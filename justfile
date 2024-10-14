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
