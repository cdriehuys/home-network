source "proxmox-iso" "debian-12" {
  proxmox_url              = "https://${var.proxmox_host}/api2/json"
  username                 = var.proxmox_username
  password                 = var.proxmox_password
  insecure_skip_tls_verify = false
  node                     = var.proxmox_node

  vm_name                 = "${trimsuffix(basename(var.iso_url), ".iso")}-${formatdate("YYYY-MM-DDThh:mm:ss", timestamp())}"
  template_description    = <<EOF
  # Debian 12 Bookworm Template

  A template for Debian VMs using cloud-init for initial provisioning.

  **Created:** ${formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())}
  EOF

  tags                    = "debian_12;template"
  os                      = "l26"
  cpu_type                = "x86-64-v2-AES"
  sockets                 = "1"
  cores                   = 2
  memory                  = 2048
  bios                    = "seabios"
  scsi_controller         = "virtio-scsi-single"
  qemu_agent              = true
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  network_adapters {
    bridge   = "vmbr0"
    firewall = true
    model    = "virtio"
  }

  disks {
    disk_size    = "10G"
    format       = "raw"
    storage_pool = "local-lvm"
    type         = "scsi"
    io_thread    = true
  }

  boot_iso {
    iso_url          = var.iso_url
    iso_checksum     = var.iso_checksum
    iso_storage_pool = "local"
    unmount          = true
  }

  http_directory = "http"
  http_port_min  = 8100
  http_port_max  = 8100
  boot_wait      = "10s"
  boot_command   = ["<esc><wait>auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter>"]

  ssh_username = "root"
  ssh_password = "packer"
  ssh_timeout  = "10m"
}
