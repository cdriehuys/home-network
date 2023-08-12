# Provisioning

This directory contains the Ansible playbooks used to provision anything and
everything.

## Overview

* __DNS:__ A set of Raspberry Pi boards running `unbound`
* __Service Discovery:__ Consul
* __Secret Management:__ Vault
* __Task Scheduling:__ Nomad
* __Virtualization:__ Proxmox

## Run It

Open the project in the defined VS Code dev container. This ensures that the
necessary environment is set up.

```bash
# This has to be done once.
echo "$VAULT_PASSWORD" > .vault_password

# Run it!
ansible-playbook -i inventory.yml

# Run a specific playbook
ansible-playbook -i inventory.yml dns.yml

# Run multiple playbooks
ansible-playbook -i inventory.yml dns.yml consul.yml
```

## Prerequisites

The requirements that have to be met by each piece of hardware on the network
before they can be provisioned.

### Proxmox VMs and Containers

Ansible expects to be able to SSH into these VMs and LXC instances as `root` to
set up its own provisioning user.

### Raspberry Pis

* SD card flashed with Raspberry Pi OS Lite
* SSH access enabled through the Raspberry Pi Imager software with the default
  username and password of `pi` and `raspberry`

This can be accomplished using either the advanced settings of `rpi-imager`, or
by writing some files to the `bootfs` of a formatted SD card.

```shell
cd path/to/mounted/bootfs
touch ssh
echo "pi:$(echo 'raspberry' | openssl passwd -6 -stdin)" > userconf
```

## Troubleshooting

### SSH Authentication Failed

The VS Code dev container connects to the SSH agent on the host to forward your
keys. On Windows, this will be the WSL backend that Docker is run through rather
than the SSH agent on the base Windows install. If you're seeing "Permission
denied: public key", make sure that the SSH agent is running in WSL.
