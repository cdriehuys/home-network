job "zwave-js" {
    datacenters = ["pve"]
    type = "service"

    constraint {
        attribute = "${meta.cluster}"
        operator = "=="
        value = "compute"
    }

    constraint {
        attribute = "${meta.zwave_device}"
        operator = "is_set"
    }

    group "zwave-js" {
        restart {
            delay = "15s"
            interval = "5m"
            mode = "delay"
        }

        network {
            port "http" {
                to = 8091
            }

            port "websocket" {
                to = 3000
            }
        }

        volume "zwave-js-store" {
            type = "host"
            read_only = false
            source = "zwave-js-store"
        }

        task "zwave-js" {
            driver = "docker"

            service {
                name = "zwave"
                port = "http"

                tags = [
                    "traefik.enable=true",
                    "traefik.http.routers.zwave.rule=Host(`zwave.proxy.lan.qidux.com`)",
                    "traefik.http.routers.zwave.tls.certresolver=lan",
                ]

                check {
                    type = "tcp"
                    port = "http"
                    interval = "10s"
                    timeout = "2s"
                }
            }

            service {
                name = "zwave-ws"
                port = "websocket"

                tags = [
                    "traefik.enable=true",
                    "traefik.http.routers.zwave-ws.rule=Host(`ws.zwave.proxy.lan.qidux.com`)",
                ]

                check {
                    type = "tcp"
                    port = "websocket"
                    interval = "10s"
                    timeout = "2s"
                }
            }

            config {
                image = "zwavejs/zwave-js-ui:8.9.0"

                devices = [
                    {
                        container_path = "/dev/zwave"
                        host_path = "${meta.zwave_device}"
                    }
                ]

                ports = ["http", "websocket"]
            }

            volume_mount {
                volume = "zwave-js-store"
                destination = "/usr/src/app/store"
                read_only = false
            }
        }
    }
}
