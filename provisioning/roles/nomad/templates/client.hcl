client {
    enabled = true
    servers = {{ groups['nomad_servers'] | to_json }}
}

plugin "docker" {}
