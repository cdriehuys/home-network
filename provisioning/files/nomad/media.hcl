job "media" {
    datacenters = ["pve"]
    type = "service"

    constraint {
        attribute = "${meta.cluster}"
        operator = "=="
        value = "compute"
    }

    group "sabnzbd" {
        constraint {
            attribute = "${node.unique.name}"
            operator = "=="
            value = "nomadcompute2"
        }

        restart {
            delay = "15s"
            interval = "5m"
            mode = "delay"
        }

        network {
            port "http" {
                to = 8080
            }
        }

        volume "sabnzbd" {
            type = "host"
            read_only = false
            source = "sabnzbd"
        }

        task "sabnzbd" {
            driver = "docker"

            service {
                name = "sabnzbd"
                port = "http"

                tags = [
                    "traefik.enable=true",
                    "traefik.http.routers.sabnzbd.rule=Host(`sabnzbd.proxy.lan.qidux.com`)",
                    "traefik.http.routers.sabnzbd.tls.certresolver=lan",
                ]

                check {
                    type = "tcp"
                    port = "http"
                    interval = "10s"
                    timeout = "2s"
                }
            }

            config {
                image = "ghcr.io/linuxserver/sabnzbd:4.3.3"
                ports = ["http"]

                volumes = [
                    "/nfs/media:/data"
                ]
            }

            env {
                PUID = "0"
                PGID = "0"
            }

            // The service was consistently restarting without additional
            // resources.
            resources {
                cpu = 1000
                memory = 1024
            }

            volume_mount {
                volume = "sabnzbd"
                destination = "/config"
                read_only = false
            }
        }
    }
}
