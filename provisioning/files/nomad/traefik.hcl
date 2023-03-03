job "traefik" {
    datacenters = ["pve"]
    type = "service"

    constraint {
        attribute = "${meta.cluster}
        operator = "=="
        value = "compute"
    }

    group "traefik" {
        count = 1

        network {
            port "http" {
                static = 80
            }

            port "https" {
                static = 443
            }

            port "api" {
                static = 8080
            }
        }

        volume "traefik-certs" {
            type = "host"
            read_only = false
            source = "traefik-certs-production"
        }

        service {
            name = "traefik"

            check {
                name = "alive"
                type = "tcp"
                port = "http"
                interval = "10s"
                timeout = "2s"
            }
        }

        task "traefik" {
            driver = "docker"

            config {
                image = "traefik:v2.9.8"
                network_mode = "host"

                volumes = [
                    "local/traefik.yml:/etc/traefik/traefik.yml"
                ]
            }

            volume_mount {
                volume = "traefik-certs"
                destination = "/etc/traefik/acme"
                read_only = false
            }

            template {
                data = <<EOF
entryPoints:
    web:
        address: ":80"
    websecure:
        address: ":443"
    traefik:
        address: ":8080"

api:
    dashboard: true
    insecure: true

providers:
    consulCatalog:
        prefix: traefik
        exposedByDefault: false

        endpoint:
            address: 127.0.0.1:8500
            scheme: http

certificatesResolvers:
    lan:
        acme:
            email: chathan@driehuys.com
            storage: /etc/traefik/acme/acme.json
            dnsChallenge:
                provider: cloudflare
EOF
                destination = "local/traefik.yml"
            }

            template {
                data = <<EOF
{{ with secret "kv/data/cloudflare" }}
CF_DNS_API_TOKEN={{ .Data.data.api_token }}
{{ end }}
EOF

                destination = "secrets/dns.env"
                env = true
            }

            resources {
                cpu = 100
                memory = 128
            }
        }
    }
}
