FROM ghcr.io/opentofu/opentofu:1.11.5-minimal@sha256:d0cddf6b5f471de1322badb0dee599f19e10b655a60787ce90445a56ac3ba970 AS tofu

FROM docker.io/library/python:3.14.3-slim@sha256:6a27522252aef8432841f224d9baaa6e9fce07b07584154fa0b9a96603af7456

ENV HOME=/work
ARG USERID=10000
ENV USERID=$USERID
ARG USERNAME=nonroot
ENV USERNAME=$USERNAME


COPY --from=tofu /usr/local/bin/tofu /usr/local/bin/tofu

# renovate: datasource=pypi depName=ansible
ARG ANSIBLE_VERSION=13.4.0

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