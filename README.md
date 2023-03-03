# Home Network

All about the home network.

## Provisioning

*See the [`provisioning/`][provisioning] directory for more details.*

There is an Ansible playbook to provision the Pi-hole instances that provide
ad-blocking across the network.


## Network Overview

Name    | Purpose         | Subnet         | VLAN
--------|-----------------|----------------|-----
Default | Default network | 192.168.1.0/24 | -

### Machines

* 2 Raspberry Pi 4s
    * Pi-hole DNS
    * Tailscale exit nodes
* 1 Proxmox node
* 1 NAS

[provisioning]: ./provisioning/README.md

