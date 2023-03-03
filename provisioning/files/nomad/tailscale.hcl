job "tailscale" {
    datacenters = ["pve"]
    type = "sysbatch"

    constraint {
        attribute = "${meta.cluster}"
        operator = "=="
        value = "dns"
    }

    group "tailscale" {
        task "tailscale" {
            # Need raw_exec because the isolation used by the normal exec driver
            # doesn't work on the Raspberry Pi machines we use.
            driver = "raw_exec"

            config {
                command = "/usr/bin/tailscale"
                args = [
                    "up",
                    "--accept-dns=false",
                    "--advertise-exit-node",
                    "--advertise-routes=192.168.1.0/24",
                    "--authkey=${TAILSCALE_AUTH_TOKEN}",
                ]
            }

            template {
                data = <<EOF
TAILSCALE_AUTH_TOKEN={{ with secret "secrets/tailscale" }}{{ .Data.auth_key }}{{ end }}
EOF
                destination = "secrets/tailscale.env"
                env = true
            }
        }
    }
}
