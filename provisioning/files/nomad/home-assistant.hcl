job "home-assistant" {
    datacenters = ["pve"]
    type = "service"

    group "home-assistant" {
        network {
            port "http" { to = 8123 }
        }

        task "ha-core" {
            driver = "docker"

            config {
                image = "homeassistant/home-assistant:2023.2.5"
                ports = ["http"]
            }

            service {
                name = "homeassistant"
                port = "http"

                tags = {
                    "traefik.enable=true",
                }

                check {
                    type = "http"
                    path = "/"
                    interval = "10s"
                    timeout = "2s"
                }
            }
        }
    }
}
