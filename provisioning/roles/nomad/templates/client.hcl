client {
    enabled = true
    servers = {{ groups['nomad_servers'] | to_json }}
    {% if nomad_client_meta %}

    meta {
        {% for key, value in nomad_client_meta.items() %}
        {{ key }} = "{{ value }}"
        {% endfor %}
    }
    {% endif %}
    {% for volume in nomad_volumes %}

    host_volume "{{ volume.name }}" {
        path = "{{ volume.path }}"
        read_only = {{ volume.read_only | to_json }}
    }
    {% endfor %}
}

plugin "docker" {}
{% if nomad_enable_raw_exec %}

plugin "raw_exec" {
    config {
        enabled = true
    }
}
{% endif %}
