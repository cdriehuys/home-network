job "home-assistant" {
    datacenters = ["pve"]
    type = "service"

    constraint {
        attribute = "${meta.cluster}"
        operator = "=="
        value = "compute"
    }

    group "home-assistant" {
        restart {
            delay = "15s"
            interval = "5m"
            mode = "delay"
        }

        network {
            port "http" { static = 8123 }
        }

        volume "home-assistant" {
            type = "host"
            read_only = false
            source = "home-assistant"
        }

        task "ha-core" {
            driver = "docker"

            service {
                name = "homeassistant"
                port = "http"

                tags = [
                    "traefik.enable=true",
                    "traefik.http.routers.homeassistant.rule=Host(`homeassistant.proxy.lan.qidux.com`)",
                    "traefik.http.routers.homeassistant.tls.certresolver=lan",
                    "traefik.http.services.homeassistant.loadbalancer.server.port=8123",
                ]

                check {
                    type = "http"
                    path = "/"
                    interval = "10s"
                    timeout = "2s"
                }
            }

            config {
                image = "ghcr.io/home-assistant/home-assistant:2024.12.5"
                network_mode = "host"

                volumes = [
                    "local/config/configuration.yaml:/config/configuration.yaml",
                    "secrets/secrets.yaml:/config/secrets.yaml",
                    "secrets/service-account.json:/config/service-account.json",
                ]
            }

            resources {
                cpu = 500
                memory = 1024
            }

            volume_mount {
                volume = "home-assistant"
                destination = "/config"
                read_only = false
            }

            artifact {
                source = "git::https://github.com/cdriehuys/home-assistant"
                destination = "local/config/"

                options {
                    ref = "2b1f4a7"
                }
            }

            template {
                data = <<EOF
{{with secret "secrets/home/location"}}
elevation: {{.Data.elevation}}
latitude: {{.Data.latitude}}
longitude: {{.Data.longitude}}
{{end}}

{{with secret "secrets/google/home-assistant"}}
google_project_id: "{{ .Data.project_id }}"{{ end}}
EOF
                destination = "secrets/secrets.yaml"
            }

            template {
                data = <<EOF
{{with secret "secrets/google/home-assistant"}}{{ .Data.service_account }}{{end}}
EOF
                destination = "secrets/service-account.json"
            }
        }

        task "cloudflare-tunnel" {
            driver = "docker"

            config {
                image = "cloudflare/cloudflared:latest"
                network_mode = "host"

                args = ["tunnel", "--no-autoupdate", "run", "home-assistant"]
            }

            template {
                data = <<EOF
TUNNEL_TOKEN={{ with secret "secrets/cloudflare/tunnels/home-assistant" }}{{ .Data.token }}{{ end }}
EOF
                destination = "secrets/tunnel.env"
                env = true
            }
        }
    }
}
