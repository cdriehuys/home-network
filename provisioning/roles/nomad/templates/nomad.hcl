datacenter = "pve"
data_dir = "{{ nomad_data_dir }}"

vault {
    enabled = true
    address = "http://active.vault.service.consul:8200"
    create_from_role = "nomad-cluster"
}
