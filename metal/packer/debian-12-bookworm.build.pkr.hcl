build {
  sources = ["source.proxmox-iso.debian-12"]

  # Using ansible playbooks to configure debian
  provisioner "ansible" {
    playbook_file    = "${path.root}/ansible/debian_config.yml"
    use_proxy        = false
    user             = "root"
    ansible_env_vars = ["ANSIBLE_HOST_KEY_CHECKING=False"]
    extra_arguments  = ["--extra-vars", "ansible_password=packer"]
  }

  # Copy default cloud-init config
  provisioner "file" {
    destination = "/etc/cloud/cloud.cfg"
    source      = "${path.root}/http/cloud.cfg"
  }

  # Copy Proxmox cloud-init config
  provisioner "file" {
    destination = "/etc/cloud/cloud.cfg.d/99-pve.cfg"
    source      = "${path.root}/http/99-pve.cfg"
  }
}
