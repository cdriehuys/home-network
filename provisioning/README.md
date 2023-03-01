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

We invoke Ansible inside a docker container to ensure we have the same
dependencies every time and to reduce the requirements on the host machine to
just Docker:

```bash
# This has to be done once.
echo "$VAULT_PASSWORD" > .vault_password

# Run it!
docker compose run ansible

# Run a specific playbook
docker compose run ansible -- dns.yml

# Run multiple playbooks
docker compose run ansible -- dns.yml consul.yml

# If editing the Docker image, don't forget the --build tag:
docker compose run --build ansible
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
