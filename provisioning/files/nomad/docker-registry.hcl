job "docker-registry" {
    datacenters = ["pve"]
    type = "service"

    constraint {
        attribute = "${meta.cluster}"
        operator = "=="
        value = "compute"
    }

    group "docker-registry" {
        network {
            port "http" {
                to = 5000
            }
        }

        volume "docker-registry" {
            type = "host"
            read_only = false
            source = "docker-registry"
        }

        task "docker-registry" {
            driver = "docker"

            service {
                name = "docker-registry"
                port = "http"

                tags = [
                    "traefik.enable=true",
                    "traefik.http.routers.registry.rule=Host(`registry.proxy.lan.qidux.com`)",
                    "traefik.http.routers.registry.tls.certresolver=lan",
                ]

                check {
                    type = "tcp"
                    port = "http"
                    interval = "10s"
                    timeout = "2s"
                }
            }

            config {
                image = "registry:2.8.1"
                ports = ["http"]
            }

            volume_mount {
                volume = "docker-registry"
                destination = "/var/lib/registry"
                read_only = false
            }
        }
    }
}
