FROM mcr.microsoft.com/devcontainers/python:0-3.11

ENV ANSIBLE_HOST_KEY_CHECKING=False \
  DEBIAN_FRONTEND=noninteractive \
  PIP_NO_CACHE_DIR=off

# Need sshpass to connect over SSH with raw passwords. This is used to connect
# as the default user for an OS in order to harden it.
RUN apt-get update && \
  apt-get install -y sshpass
