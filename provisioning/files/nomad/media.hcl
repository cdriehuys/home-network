job "media" {
    datacenters = ["pve"]
    type = "service"

    constraint {
        attribute = "${meta.cluster}"
        operator = "=="
        value = "compute"
    }

    group "prowlarr" {
        constraint {
            attribute = "${node.unique.name}"
            operator = "=="
            value = "nomadcompute1"
        }

        restart {
            delay = "15s"
            interval = "5m"
            mode = "delay"
        }

        network {
            port "http" {
                to = 9696
            }
        }

        volume "prowlarr" {
            type = "host"
            read_only = false
            source = "prowlarr"
        }

        task "prowlarr" {
            driver = "docker"

            service {
                name = "prowlarr"
                port = "http"

                tags = [
                    "traefik.enable=true",
                    "traefik.http.routers.prowlarr.rule=Host(`prowlarr.proxy.lan.qidux.com`)",
                    "traefik.http.routers.prowlarr.tls.certresolver=lan",
                ]

                check {
                    type = "tcp"
                    port = "http"
                    interval = "10s"
                    timeout = "2s"
                }
            }

            config {
                image = "ghcr.io/linuxserver/prowlarr:1.23.1"
                ports = ["http"]

                volumes = [
                    "/nfs/media:/data"
                ]
            }

            volume_mount {
                volume = "prowlarr"
                destination = "/config"
                read_only = false
            }
        }
    }

    group "radarr" {
        constraint {
            attribute = "${node.unique.name}"
            operator = "=="
            value = "nomadcompute1"
        }

        restart {
            delay = "15s"
            interval = "5m"
            mode = "delay"
        }

        network {
            port "http" {
                to = 7878
            }
        }

        volume "radarr" {
            type = "host"
            read_only = false
            source = "radarr"
        }

        task "radarr" {
            driver = "docker"

            service {
                name = "radarr"
                port = "http"

                tags = [
                    "traefik.enable=true",
                    "traefik.http.routers.radarr.rule=Host(`radarr.proxy.lan.qidux.com`)",
                    "traefik.http.routers.radarr.tls.certresolver=lan",
                ]

                check {
                    type = "tcp"
                    port = "http"
                    interval = "10s"
                    timeout = "2s"
                }
            }

            config {
                image = "ghcr.io/linuxserver/radarr:5.9.1"
                ports = ["http"]

                volumes = [
                    "/nfs/media:/data"
                ]
            }


            volume_mount {
                volume = "radarr"
                destination = "/config"
                read_only = false
            }
        }
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
