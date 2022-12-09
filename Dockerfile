FROM ubuntu:jammy
LABEL maintainer="Thomas Farvour <tom@farvour.com>"

ARG DEBIAN_FRONTEND=noninteractive

# Top level directory where everything related to the Satisfactory server
# is installed to. Since you can bind-mount data volumes for worlds,
# saves or other things, this doesn't really have to change, but is
# here for clarity and customization in case.

ENV SERVER_COMPONENT_NAME=satisfactory
ENV SERVER_HOME=/opt/${SERVER_COMPONENT_NAME}
ENV SERVER_INSTALL_DIR=/opt/${SERVER_COMPONENT_NAME}/${SERVER_COMPONENT_NAME}-dedicated-server
ENV SERVER_DATA_DIR=/var/opt/${SERVER_COMPONENT_NAME}/data

# Steam still requires 32-bit cross compilation libraries.
RUN echo "=== Installing necessary system packages to support steam CLI installation..." \
    && apt update \
    && apt install -yy --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    dumb-init \
    expect \
    git \
    gosu \
    htop \
    lib32gcc-s1 \
    net-tools \
    netcat \
    pigz \
    rsync \
    telnet \
    tmux \
    unzip \
    vim \
    wget \
    && apt clean -y && rm -rf /var/lib/apt/lists/*

# Non-privileged user ID.
ENV PROC_UID 7991
ENV PROC_USER satisfactory
ENV PROC_GROUP nogroup

RUN echo "=== Create a non-privileged user to run with..." \
    && useradd -u ${PROC_UID} -d ${SERVER_HOME} -g ${PROC_GROUP} ${PROC_USER}

RUN echo "=== Create server directories..." \
    && mkdir -p ${SERVER_HOME} \
    && mkdir -p ${SERVER_INSTALL_DIR} \
    && mkdir -p ${SERVER_DATA_DIR} \
    && mkdir -p ${SERVER_HOME}/Steam \
    && chown -R ${PROC_USER}:${PROC_GROUP} ${SERVER_HOME}

USER ${PROC_USER}

WORKDIR ${SERVER_HOME}

RUN echo "=== Downloading and installing steamcmd..." \
    && cd Steam \
    && wget https://media.steampowered.com/installer/steamcmd_linux.tar.gz \
    && tar -zxvf steamcmd_linux.tar.gz \
    && chown -R ${PROC_USER}:${PROC_GROUP} . \
    && cd -

# This is most likely going to be the largest layer created; all the game
# files for the dedicated server. NOTE: It is a good idea to do as much as
# possible _beyond_ this point to avoid Docker having to re-create it.
RUN echo "=== Downloading and installing server with steamcmd..." \
    && ${SERVER_HOME}/Steam/steamcmd.sh \
    +login anonymous \
    +force_install_dir ${SERVER_INSTALL_DIR} \
    +app_update 1690800 -beta experimental validate \
    +quit

# Install custom startserver script.

COPY --chown=${PROC_USER}:${PROC_GROUP} scripts/startserver-1.sh ${SERVER_INSTALL_DIR}/

# Switch back to root user to allow entrypoint to drop privileges.
USER root

# Default game ports.
EXPOSE 15000/tcp 15000/udp
EXPOSE 15777/tcp 15777/udp
EXPOSE 7777/tcp 7777/udp

# Install custom entrypoint script.
COPY scripts/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/usr/bin/dumb-init", "--rewrite", "15:2", "--", "/entrypoint.sh"]
CMD ["./startserver-1.sh"]
