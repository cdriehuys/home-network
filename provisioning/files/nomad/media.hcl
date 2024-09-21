job "media" {
    datacenters = ["pve"]
    type = "service"

    constraint {
        attribute = "${meta.cluster}"
        operator = "=="
        value = "compute"
    }

    group "nzbget" {
        restart {
            delay = "15s"
            interval = "5m"
            mode = "delay"
        }

        network {
            port "http" {
                to = 6789
            }
        }

        volume "nzbget" {
            type = "host"
            read_only = false
            source = "nzbget"
        }

        task "nzbget" {
            driver = "docker"

            service {
                name = "nzbget"
                port = "http"

                tags = [
                    "traefik.enable=true",
                    "traefik.http.routers.nzbget.rule=Host(`nzbget.proxy.lan.qidux.com`)",
                    "traefik.http.routers.nzbget.tls.certresolver=lan",
                ]

                check {
                    type = "tcp"
                    port = "http"
                    interval = "10s"
                    timeout = "2s"
                }
            }

            config {
                image = "ghcr.io/linuxserver/nzbget:24.3.20240913"
                ports = ["http"]

                volumes = [
                    "/nfs/media:/data"
                ]
            }

            env {
                PUID = "0"
                PGID = "0"
            }

            volume_mount {
                volume = "nzbget"
                destination = "/config"
                read_only = false
            }
        }
    }

    group "prowlarr" {
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

            env {
                PUID = "0"
                PGID = "0"
            }


            volume_mount {
                volume = "radarr"
                destination = "/config"
                read_only = false
            }
        }
    }


    group "sonarr" {
        restart {
            delay = "15s"
            interval = "5m"
            mode = "delay"
        }

        network {
            port "http" {
                to = 8989
            }
        }

        volume "sonarr" {
            type = "host"
            read_only = false
            source = "sonarr"
        }

        task "sonarr" {
            driver = "docker"

            service {
                name = "sonarr"
                port = "http"

                tags = [
                    "traefik.enable=true",
                    "traefik.http.routers.sonarr.rule=Host(`sonarr.proxy.lan.qidux.com`)",
                    "traefik.http.routers.sonarr.tls.certresolver=lan",
                ]

                check {
                    type = "tcp"
                    port = "http"
                    interval = "10s"
                    timeout = "2s"
                }
            }

            config {
                image = "ghcr.io/linuxserver/sonarr:4.0.9"
                ports = ["http"]

                volumes = [
                    "/nfs/media:/data"
                ]
            }

            env {
                PUID = "0"
                PGID = "0"
            }

            volume_mount {
                volume = "sonarr"
                destination = "/config"
                read_only = false
            }
        }
    }
}
