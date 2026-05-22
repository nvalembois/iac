FROM ghcr.io/opentofu/opentofu:1.12.0-minimal@sha256:8b9b39254e995fdcb904e83df2e4ae651110f8804d4c6e4bc170cff1a89a816a AS tofu

FROM docker.io/library/python:3.14.5-slim@sha256:c845af9399020c7e562969a13689e929074a10fd057acd1b1fad06a2fb068e97

ENV HOME=/work
ARG USERID=10000
ENV USERID=$USERID
ARG USERNAME=nonroot
ENV USERNAME=$USERNAME


COPY --from=tofu /usr/local/bin/tofu /usr/local/bin/tofu

# renovate: datasource=pypi depName=ansible
ARG ANSIBLE_VERSION=13.7.0

RUN set -e && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes \
          curl git jq yq && \
    DEBIAN_FRONTEND=noninteractive apt-get clean --yes && \
    pip3 install --root-user-action ignore --no-build --no-cache \
          ansible==$ANSIBLE_VERSION requests python-openstackclient && \
    install -d -o $USERID -g root -m 0750 $HOME && \
    adduser -u $USERID --no-create-home --disabled-password --home $HOME --comment 'non root user' $USERNAME

USER $USERID
VOLUME $HOME
WORKDIR $HOME