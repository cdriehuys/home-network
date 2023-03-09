job "magic-mirror" {
    datacenters = ["pve"]
    type = "service"

    constraint {
        attribute = "${meta.cluster}"
        operator = "=="
        value = "compute"
    }

    group "magic-mirror" {
        network {
            port "http" {
                to = 8080
            }
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
                    type = "tcp"
                    port = "http"
                    interval = "10s"
                    timeout = "2s"
                }
            }

            config {
                image = "registry.proxy.lan.qidux.com/magic-mirror:latest"
                ports = ["http"]

                command = "npm"
                args = ["run", "server"]

                volumes = [
                    "local/config.js:/opt/magic_mirror/config/config.js"
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
			module: "calendar",
			header: "US Holidays",
			position: "top_left",
			config: {
				calendars: [
					{
						symbol: "calendar-check",
						url: "webcal://www.calendarlabs.com/ical-calendar/ics/76/US_Holidays.ics"
					}
				]
			}
		},
		{
			module: "compliments",
			position: "lower_third"
		},
		{
			module: "newsfeed",
			position: "bottom_bar",
			config: {
				feeds: [
					{
						title: "New York Times",
						url: "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml"
					}
				],
				showSourceTitle: true,
				showPublishDate: true,
				broadcastNewsFeeds: true,
				broadcastNewsUpdates: true
			}
		},
	]
};

/*************** DO NOT EDIT THE LINE BELOW ***************/
if (typeof module !== "undefined") {module.exports = config;}
EOF
                destination = "local/config.js"
            }
        }
    }
}
