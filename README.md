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

## History

### Kubernetes Cluster (2024-present)

__Components:__
* One Proxmox node
  * One K3s server
  * Three K3s agents
* Argo CD for workloads

I wanted to try out Kubernetes since I hadn't used it in a while, and it's a
much more popular platform than Nomad. I also took this opportunity to add more
automation when spinning up VMs.

Proxmox templates are now automatically provisioned through Packer, and VMs are
provisioned through Terraform. Shifting to VM templates for base configuration
greatly cut down the provisioning time. Instead of always running the Ansible
tasks to provision from scratch, those tasks are mainly handled during template
creation, and the typical provisioning process is much shorter.

### Nomad Cluster (2023-present)

I'm slowly shifting workloads from Nomad to Kubernetes, but some tasks are
still running on Nomad.

__Components:__
* One Proxmox node
  * 3 Consul servers
  * 2 Vault servers
  * 3 Nomad servers
  * 2 Nomad compute nodes

VMs were created manually through Proxmox, then provisioned with Ansible. Jobs
were run in containers orchestrated through Nomad. Access to applications was
proxied through Traefik, using the Consul integration to discover which services
should be exposed.

## Troubleshooting

### External DNS Failures

Services that required external networking were failing. This included jobs
running on Nomad and Kubernetes. The root cause was the second DNS server
failing to respond to queries because its clock was out of sync.

It's possible the time was too out of sync for systemd to keep it in sync.
Manually setting the time to the approximate current time and then rebooting the
system corrected the issue.


[provisioning]: ./provisioning/README.md

