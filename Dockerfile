FROM ghcr.io/opentofu/opentofu:1.12.1-minimal@sha256:fbfeb438edb0d0116239096964595c7cbe57d9c9924359d8fa86297cf0f0f810 AS tofu

FROM docker.io/library/python:3.14.6-slim@sha256:fe45aec842a1256ca15d90f319f943c34c6d1ad0585f3c3cd4009ae23c4e932d

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