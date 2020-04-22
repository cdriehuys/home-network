# Provisioning

This directory contains the Ansible playbooks used to provision anything and
everything.

## Run It

We invoke Ansible inside a docker container to ensure we have the same
dependencies every time and to reduce the requirements on the host machine to
just Docker (and `docker-compose`):

```bash
docker-compose run ansible
```

## Prerequisites

The requirements that have to be met by each piece of hardware on the network
before they can be provisioned.

## Raspberry Pis

* SD card flashed with Raspbian. We don't need the desktop environment so we can
  use Raspbian Lite.
* SSH access enabled by `touch /path/to/boot/ssh`
