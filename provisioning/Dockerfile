FROM python:3

WORKDIR /opt/provisioning

ENV ANSIBLE_HOST_KEY_CHECKING=False

# Need sshpass to connect over SSH with raw passwords. This is used to connect
# as the default user for an OS in order to harden it.
RUN apt-get update && \
  apt-get install -y sshpass && \
  pip install --upgrade pip && \
  pip install 'ansible==7.1.0'

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

COPY requirements.yml /tmp/requirements.yml
RUN ansible-galaxy install -r /tmp/requirements.yml && \
    rm /tmp/requirements.yml
