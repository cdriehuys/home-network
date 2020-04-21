FROM python:3.8

WORKDIR /opt/provisioning

ENV ANSIBLE_HOST_KEY_CHECKING=False

# Need sshpass to connect over SSH with raw passwords. This is used to connect
# as the default user for an OS in order to harden it.
RUN apt-get update && \
 apt-get install -y sshpass && \
 pip install 'ansible==2.9.7'
