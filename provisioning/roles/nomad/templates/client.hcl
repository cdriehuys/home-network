client {
    enabled = true
    servers = {{ groups['nomad_servers'] | to_json }}
    {% for volume in nomad_volumes %}

    host_volume "{{ volume.name }}" {
        path = "{{ volume.path }}"
        read_only = {{ volume.read_only | to_json }}
    }
    {% endfor %}
}

plugin "docker" {}
