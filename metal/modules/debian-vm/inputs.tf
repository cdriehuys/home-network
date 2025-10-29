variable "name" {
    type = string
    description = "The name of the VM. Must be a valid DNS name."
}

variable "cpu_cores" {
    type = number
    description = "The number of CPU cores to allocate to the VM."
}

variable "memory" {
    type = number
    description = "The amount of memory to allocate to the VM in megabytes."
}

variable "authorized_keys" {
    type = list(string)
    description = "The SSH keys used to access the VM."
}

variable "disk_size" {
    type = number
    description = "Disk size in GB"
    default = 8
}

variable "tags" {
    type = list(string)
    description = "Tags to add to the VM."
    default = []
}

variable "username" {
    type = string
    description = "The name of the user created for provisioning the VM."
    default = "provisioning"
}

variable "ipv4_address" {
    type = string
    description = "Static IP address to assign"
    default = ""
}
