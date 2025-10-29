terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "~> 0.66"
    }
  }
}

locals {
  default_tags = toset(["debian", "terraform"])
  full_tags    = sort(tolist(setunion(local.default_tags, toset(var.tags))))
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

resource "proxmox_virtual_environment_vm" "this" {
  name        = var.name
  description = "Managed by Terraform"
  tags        = local.full_tags

  node_name = "pve"

  clone {
    vm_id = local.debian_template_latest
  }

  cpu {
    cores = var.cpu_cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory
    // Floating set to same value to enable ballooning
    floating = var.memory
  }

  disk {
    interface = "scsi0"
    size = var.disk_size
  }

  initialization {
    dynamic "ip_config" {
      for_each = var.ipv4_address == "" ? [] : [""]

      content {
        ipv4 {
          address = "${var.ipv4_address}/24"
          gateway = "192.168.1.1"
        }
      }
    }

    user_account {
      keys     = [for key in var.authorized_keys : trimspace(key)]
      username = var.username
    }
  }

  network_device {
    bridge = "vmbr0"
  }
}
