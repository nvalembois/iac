FROM ghcr.io/opentofu/opentofu:1.13.10-minimal@sha256:5f60d133a3724d217d5aad91d8e94c2c86c0c8fec5656a7754fd24710f5473c0 AS tofu

FROM docker.io/library/python:3.15.2-slim@sha256:08a4c22c92b79ec821a7ad49768480039ee5b7accac3955228e75366e30abc8e

ENV HOME=/work
ARG USERID=10000
ENV USERID=$USERID
ARG USERNAME=nonroot
ENV USERNAME=$USERNAME


COPY --from=tofu /usr/local/bin/tofu /usr/local/bin/tofu

# renovate: datasource=pypi depName=ansible
ARG ANSIBLE_VERSION=14.6.0

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