datacenter = "pve"
data_dir = "/opt/consul/data"
encrypt = "{{ consul_encryption_key }}"

retry_join = {{ groups['consul'] | difference([inventory_hostname]) | to_json }}

acl {
    enabled = true
    default_policy = "allow"
    enable_token_persistence = true
}
