job "home-assistant" {
    datacenters = ["pve"]
    type = "service"

    group "home-assistant" {
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
                image = "homeassistant/home-assistant:2023.2.5"
                network_mode = "host"

                volumes = [
                    "local/configuration.yaml:/config/configuration.yaml",
                    "secrets/secrets.yaml:/config/secrets.yaml"
                ]
            }

            volume_mount {
                volume = "home-assistant"
                destination = "/config"
                read_only = false
            }

            template {
                data = <<EOF
homeassistant:
  name: Home
  elevation: !secret elevation
  latitude: !secret latitude
  longitude: !secret longitude
  temperature_unit: F
  time_zone: America/New_York
  unit_system: imperial
  currency: USD
  language: en
  country: US
  internal_url: https://homeassistant.proxy.lan.qidux.com
  external_url: https://homeassistant.qidux.com

http:
  use_x_forwarded_for: true
  trusted_proxies:
    # Internal network
    - 192.168.1.0/24
    # Localhost for cloudflare tunnel
    - 127.0.0.1
    - "::1"

# Loads default set of integrations. Do not remove.
default_config:

# Load frontend themes from the themes folder
frontend:
  themes: !include_dir_merge_named themes

# Text to speech
tts:
  - platform: google_translate

automation: !include automations.yaml
script: !include scripts.yaml
scene: !include scenes.yaml
EOF
                destination = "local/configuration.yaml"
            }

            template {
                data = <<EOF
{{with secret "kv/data/home-assistant"}}
elevation: {{.Data.data.elevation}}
latitude: {{.Data.data.latitude}}
longitude: {{.Data.data.longitude}}
{{end}}
EOF
                destination = "secrets/secrets.yaml"
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
TUNNEL_TOKEN={{ with secret "kv/data/cloudflare/tunnels/home-assistant" }}{{ .Data.data.token }}{{ end }}
EOF
                destination = "secrets/tunnel.env"
                env = true
            }
        }
    }
}
