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

data "proxmox_virtual_environment_vms" "debian_templates" {
  tags = ["debian_12", "template"]

  filter {
    name   = "template"
    values = [true]
  }

  filter {
    name   = "status"
    values = ["stopped"]
  }
}

locals {
  debian_template_vms_by_name = {
    for vm in data.proxmox_virtual_environment_vms.debian_templates.vms : vm.name => vm.vm_id
  }
  debian_template_names  = sort(keys(local.debian_template_vms_by_name))
  debian_template_latest = local.debian_template_vms_by_name[local.debian_template_names[length(local.debian_template_names) - 1]]
}

resource "proxmox_virtual_environment_vm" "k8s_master" {
  name        = "k8s-master"
  description = "Managed by Terraform"
  tags        = ["debian", "k8s", "terraform"]

  node_name = "pve"

  clone {
    vm_id = local.debian_template_latest
  }

  cpu {
    cores = 1
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
    // Floating set to same value to enable ballooning
    floating = 2048
  }

  initialization {
    user_account {
      keys = [
        trimspace(resource.tls_private_key.provisioning_key.public_key_openssh)
      ]
      username = "provisioning"
    }
  }

  network_device {
    bridge = "vmbr0"
  }
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
    "k8s_master": [for ip in resource.proxmox_virtual_environment_vm.k8s_master.ipv4_addresses : ip if startswith(ip[0], "192.168.")][0][0]
  }
}
