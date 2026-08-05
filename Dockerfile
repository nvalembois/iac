FROM ghcr.io/opentofu/opentofu:1.12.5-minimal@sha256:1f7144058e8f7ac678fa711f8434b0a4570ba629d0fba2e636bcd0319dca99de AS tofu

FROM docker.io/library/python:3.14.7-slim@sha256:83c1cebb322d099ac9e3a3a532ba74b0146d702838b25e4c75c02fa81ffeb910

ENV HOME=/work
ARG USERID=10000
ENV USERID=$USERID
ARG USERNAME=nonroot
ENV USERNAME=$USERNAME


COPY --from=tofu /usr/local/bin/tofu /usr/local/bin/tofu

# renovate: datasource=pypi depName=ansible
ARG ANSIBLE_VERSION=13.8.0

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