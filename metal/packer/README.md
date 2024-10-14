# Packer

Packer is used to produce VM templates for Proxmox.

This configuration is heavily inspired by
[jacaudi's work][jacaudi-packer-template] on Debian 11 templates. The major
differences from that project are:
* The `preseed.cfg` file for Debian is based on
  [the Bookworm example][debian-preseed-example]
* `cloud.cfg` has been updated based on breaking changes and new deprecations in
  newer `cloud-init` versions

## Configuration

Create `local.auto.pkrvars.hcl` with the following contents:
```hcl
proxmox_host     = "0.0.0.0:8006"
proxmox_username = "change me"
proxmox_password = "change me"
```

## Execution

To build the template, make sure all Packer providers are installed, then run
the build:

```shell
packer init .
packer build .
```

## Packer HTTP Server Connection

During the build, Packer spins up an HTTP server which the build container can
access. This is useful for providing preseed files from the repository. Ensuring
that this server is accessible from Proxmox is crucial to successfully building
the template.

[debian-preseed-example]: https://www.debian.org/releases/bookworm/example-preseed.txt
[jacaudi-packer-template]: https://github.com/jacaudi/packer-template-debian-11
