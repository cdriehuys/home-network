FROM python:3

WORKDIR /opt/provisioning

ENV ANSIBLE_HOST_KEY_CHECKING=False \
  PIP_NO_CACHE_DIR=off

# Need sshpass to connect over SSH with raw passwords. This is used to connect
# as the default user for an OS in order to harden it.
RUN apt-get update && \
  apt-get install -y sshpass

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "site.yml" ]

COPY requirements.txt requirements.yml /tmp/
RUN pip install --upgrade pip && \
  pip install -r /tmp/requirements.txt &&\
  ansible-galaxy install -r /tmp/requirements.yml && \
  rm /tmp/requirements.txt /tmp/requirements.yml
