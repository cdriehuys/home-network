FROM mcr.microsoft.com/devcontainers/python:0-3.11

ENV ANSIBLE_HOST_KEY_CHECKING=False \
    ANSIBLE_VAULT_PASSWORD_FILE=/workspaces/home-network/provisioning/.vault_password \
    PIP_NO_CACHE_DIR=off \
    CONSUL_HTTP_ADDR=http://consul.service.consul:8500 \
    NOMAD_ADDR=http://nomad.service.consul:4646 \
    VAULT_ADDR=http://active.vault.service.consul:8200

RUN \
    # Hashicorp signing key
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    # Hashicorp repositories
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
    # Pick up repo changes
    && apt-get update \
    # Install:
    # - Hashicorp tooling
    # - sshpass in order to connect to newly provisioned hosts with a username/
    #   password to upload an SSH key.
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        consul \
        nomad \
        packer \
        sshpass \
        vault \
    # Cannot use the vault binary without setting the capabilities:
    # https://github.com/hashicorp/vault/issues/10924
    && setcap -r /usr/bin/vault

# Enable autocompletion for Hashicorp tooling
USER vscode
RUN consul -autocomplete-install \
    && nomad -autocomplete-install \
    && packer -autocomplete-install \
    && vault -autocomplete-install
