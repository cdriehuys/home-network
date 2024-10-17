variable "proxmox_api_token" {
    type = string
    description = "API token for authentication with proxmox."
}

variable "network_cidr" {
    type = string
    description = "CIDR block for the network"
    default = "192.168.1.0/24"
}
