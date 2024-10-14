output "ipv4_address" {
    description = "The IPv4 address of the VM accessible from the rest of the LAN"
    value = [for ip in resource.proxmox_virtual_environment_vm.this.ipv4_addresses : ip if startswith(ip[0], "192.168.")][0][0]
}
