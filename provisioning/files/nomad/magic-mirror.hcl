job "magic-mirror" {
    datacenters = ["pve"]
    type = "service"

    constraint {
        attribute = "${meta.cluster}"
        operator = "=="
        value = "compute"
    }

    group "magic-mirror" {
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

        update {
            auto_promote = true
            auto_revert = true
            canary = 1
            min_healthy_time = "15s"
            healthy_deadline = "1m"
        }

        volume "magic-mirror-config" {
            type = "host"
            read_only = false
            source = "magic-mirror-config"
        }

        volume "magic-mirror-css" {
            type = "host"
            read_only = false
            source = "magic-mirror-css"
        }

        task "magic-mirror" {
            driver = "docker"

            service {
                name = "magic-mirror"
                port = "http"

                tags = [
                    "traefik.enable=true",
                    "traefik.http.routers.magicmirror.rule=Host(`magic-mirror.proxy.lan.qidux.com`)",
                    "traefik.http.routers.magicmirror.tls.certresolver=lan",
                ]

                check {
                    type = "http"
                    port = "http"
                    path = "/"
                    interval = "10s"
                    timeout = "2s"
                }
            }

            env {
                // Set to same timezone as mirror client so that calendar dates
                // are correct. The mirror client can't just use UTC as well
                // because then the clock it displays is also in UTC.
                TZ = "America/New_York"
            }

            config {
                image = "registry.proxy.lan.qidux.com/magic-mirror:latest"
                ports = ["http"]

                command = "npm"
                args = ["run", "server"]

                volumes = [
                    "secrets/config.js:/opt/magic_mirror/config/config.js"
                ]
            }

            volume_mount {
                volume = "magic-mirror-config"
                destination = "/opt/magic_mirror/config"
                read_only = false
            }

            volume_mount {
                volume = "magic-mirror-css"
                destination = "/opt/magic_mirror/css"
                read_only = false
            }

            template {
                data = <<EOF
/* MagicMirror² Config Sample
 *
 * By Michael Teeuw https://michaelteeuw.nl
 * MIT Licensed.
 *
 * For more information on how you can configure this file
 * see https://docs.magicmirror.builders/configuration/introduction.html
 * and https://docs.magicmirror.builders/modules/configuration.html
 */
let config = {
    address: "0.0.0.0",
    port: 8080,
    basePath: "/",
    ipWhitelist: ["192.168.1.0/24"],

    useHttps: false, 		// Support HTTPS or not, default "false" will use HTTP
    httpsPrivateKey: "", 	// HTTPS private key path, only require when useHttps is true
    httpsCertificate: "", 	// HTTPS Certificate path, only require when useHttps is true

    language: "en",
    locale: "en-US",
    logLevel: ["INFO", "LOG", "WARN", "ERROR"], // Add "DEBUG" for even more logging
    timeFormat: 24,
    units: "imperial",
    serverOnly: true,

    modules: [
        {
            module: "alert",
        },
        {
            module: "updatenotification",
            position: "top_bar"
        },
        {
            module: "clock",
            position: "top_left"
        },
        {
            module: "weather",
            position: "top_right",
            config: {
                type: "current",
                weatherProvider: "weathergov",
                apiBase: "https://api.weather.gov/points/",
                lat: "{{ with secret "secrets/home/location" }}{{ .Data.latitude }}{{ end }}",
                lon: "{{ with secret "secrets/home/location" }}{{ .Data.longitude }}{{ end }}",
                roundTemp: true,
            }
        },
        {
            module: "weather",
            position: "top_right",
            config: {
                type: "forecast",
                weatherProvider: "weathergov",
                apiBase: "https://api.weather.gov/points/",
                lat: "{{ with secret "secrets/home/location" }}{{ .Data.latitude }}{{ end }}",
                lon: "{{ with secret "secrets/home/location" }}{{ .Data.longitude }}{{ end }}",
                roundTemp: true,
            }
        },
        {
            module: "calendar",
            position: "bottom_left",
            config: {
                calendars: [
                    {{ with secret "secrets/google/calendar/personal" }}{
                        url: "{{ .Data.ics_url }}"
                    },{{ end }}
                ]
            }
        },
        {
            module: "MMM-Todoist",
            position: "bottom_left",
            header: "Todo",
            config: {
                accessToken: "{{ with secret "secrets/todoist" }}{{ .Data.access_token }}{{ end }}",
                maximumEntries: 10,
                projects: [{{ with secret "secrets/todoist" }}{{ .Data.project_id }}{{ end }}],
                labels: ["Mirror"],
                showProject: false,
                displayTasksWithinDays: 7,
            },
        },
    ]
};

/*************** DO NOT EDIT THE LINE BELOW ***************/
if (typeof module !== "undefined") {module.exports = config;}
EOF
                destination = "secrets/config.js"
            }
        }
    }
}
