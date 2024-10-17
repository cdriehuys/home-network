terraform {

  cloud {
    hostname     = "app.terraform.io"
    organization = "cdriehuys-lan"
    workspaces {
      tags = ["homelab"]
    }
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.66"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://pve.lan.qidux.com:8006"
  api_token = var.proxmox_api_token
  tmp_dir   = "/var/tmp"

  ssh {
    agent    = true
    username = "root"
  }
}

resource "tls_private_key" "provisioning_key" {
  algorithm = "ED25519"
}

module "k8s_server" {
  source = "./modules/debian-vm"

  name = "k8s-server"
  tags = ["k8s"]

  cpu_cores = 2
  memory = 2048
  authorized_keys = [resource.tls_private_key.provisioning_key.public_key_openssh]

  ipv4_address = cidrhost(var.network_cidr, 5)
}

module "k8s_agents" {
  source = "./modules/debian-vm"

  count = 3

  name = "k8s-agent-${count.index + 1}"
  tags = ["k8s"]

  cpu_cores = 1
  memory = 1024
  authorized_keys = [resource.tls_private_key.provisioning_key.public_key_openssh]

  ipv4_address = cidrhost(var.network_cidr, 6 + count.index)
}

output "provisioning_key_private" {
  description = "SSH private key used to provision VMs"
  sensitive = true
  value = resource.tls_private_key.provisioning_key.private_key_openssh
}

output "provisioning_key_public" {
  description = "SSH public key for provisioning VMs"
  value = resource.tls_private_key.provisioning_key.public_key_openssh
}

output "vms" {
  value = {
    "k8s_server": module.k8s_server.ipv4_address,
    "k8s_agents": [for vm in module.k8s_agents : vm.ipv4_address]
  }
}
