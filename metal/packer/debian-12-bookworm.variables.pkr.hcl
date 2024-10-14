variable "iso_url" {
  type        = string
  description = "URL to download the base image from."
  default     = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.7.0-amd64-netinst.iso"
}

variable "iso_checksum" {
  type        = string
  description = "Checksum for the base image ISO."
  default     = "sha256:8fde79cfc6b20a696200fc5c15219cf6d721e8feb367e9e0e33a79d1cb68fa83"
}

variable "proxmox_host" {
  type        = string
  description = "Hostname (and port) used to connect to Proxmox"
}

variable "proxmox_username" {
  type        = string
  description = "Username for Proxmox authentication. May also be used for API token auth."
}

variable "proxmox_password" {
  type        = string
  description = "Password for Proxmox authentication. Set to 'token' for API token auth."
}

variable "proxmox_node" {
  type        = string
  description = "Node to build the image on."
  default     = "pve"
}
