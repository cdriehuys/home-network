# {{ ansible_managed }}

consul {
    address = "127.0.0.1:8500"
}

template {
    contents = <<EOF
server:
{% for service in unbound_consul_services %}
    local-zone: "{{ service.domain }}" redirect
[[- range service "{{ service.name }}" ]]
    local-data: "{{ service.domain }} 30 IN A [[ .Address ]]"[[ end ]]
{% endfor %}
EOF
    destination = "/etc/unbound/unbound.conf.d/consul.conf"

    left_delimiter = "[["
    right_delimiter = "]]"

    exec {
        splay = "5s"
        command = "unbound-control reload || true"
    }
}
