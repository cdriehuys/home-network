datacenter = "pve"
data_dir = "/opt/consul/data"
encrypt = "{{ consul_encryption_key }}"

bind_addr = "{% raw %}{{ GetPrivateInterfaces | attr \"address\" }}{% endraw %}"

retry_join = {{ groups['consul'] | difference([inventory_hostname]) | to_json }}

acl {
    enabled = false
    default_policy = "allow"
    enable_token_persistence = true
}
