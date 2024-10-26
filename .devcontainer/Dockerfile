FROM mcr.microsoft.com/devcontainers/python:3.11-bookworm

ENV ANSIBLE_HOST_KEY_CHECKING=False \
    ANSIBLE_VAULT_PASSWORD_FILE=/workspaces/home-network/provisioning/.vault_password \
    PIP_NO_CACHE_DIR=off \
    CONSUL_HTTP_ADDR=http://consul.service.consul:8500 \
    NOMAD_ADDR=http://nomad.service.consul:4646 \
    VAULT_ADDR=http://active.vault.service.consul:8200 \
    KUBECONFIG=/workspaces/home-network/platform/.kubeconfig

RUN \
    # Hashicorp signing key
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    # Hashicorp repositories
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
    # Pick up repo changes
    && apt-get update \
    # Install:
    # - Hashicorp tooling
    # - Kubernetes client
    # - sshpass in order to connect to newly provisioned hosts with a username/
    #   password to upload an SSH key.
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        consul \
        kubernetes-client \
        nomad \
        packer \
        sshpass \
        vault \
    # Cannot use the vault binary without setting the capabilities:
    # https://github.com/hashicorp/vault/issues/10924
    && setcap -r /usr/bin/vault

# ArgoCD CLI
RUN curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 \
    && install -m 555 argocd-linux-amd64 /usr/local/bin/argocd \
    && rm argocd-linux-amd64

ARG HELM_VERSION=3.16.2
ARG HELM_CHECKSUM=9318379b847e333460d33d291d4c088156299a26cd93d570a7f5d0c36e50b5bb
RUN curl -sSL -o /tmp/helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && echo "${HELM_CHECKSUM} helm.tar.gz" | sha256sum -c - \
    && tar -C /tmp -xzf /tmp/helm.tar.gz \
    && install /tmp/linux-amd64/helm /usr/local/bin/helm \
    && rm /tmp/helm.tar.gz

# Completions system-wide
RUN kubectl completion zsh > "/usr/share/zsh/vendor-completions/_kubectl" \
    && argocd completion zsh > "/usr/share/zsh/vendor-completions/_argocd" \
    && helm completion zsh > "/usr/share/zsh/vendor-completions/_helm"

# Competions just for the user
USER vscode
RUN consul -autocomplete-install \
    && nomad -autocomplete-install \
    && packer -autocomplete-install \
    && vault -autocomplete-install

# Install `just` locally. This will be available from apt in Debian 13.
RUN pipx install rust-just \
    && just --completions zsh | sudo tee /usr/share/zsh/vendor-completions/_just
