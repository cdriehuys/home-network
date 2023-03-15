# {{ ansible_managed }}

service {
    name = "{{ consul_service_name }}"
    port = {{ consul_service_port }}

    tags = [
        {% if consul_service_hostname %}
        "traefik.enable=true",
        "traefik.http.routers.{{ consul_service_name }}.rule=Host(`{{ consul_service_hostname }}`)",
        "traefik.http.routers.{{ consul_service_name }}.tls.certresolver=lan",
        "traefik.http.services.{{ consul_service_name }}.loadbalancer.server.port={{ consul_service_port }}",
        {% endif %}
    ]

    checks = [
        {% for check in consul_service_checks %}
        {
            interval = "10s"
            deregister_critical_service_after = "1h"
            http = "http://localhost:{{ consul_service_port }}{{ check.path}}"
        },
        {% endfor %}
    ]
}
