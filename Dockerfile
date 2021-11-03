FROM ubuntu:bionic
LABEL maintainer="Thomas Farvour <tom@farvour.com>"

ARG DEBIAN_FRONTEND=noninteractive

# Top level directory where everything related to the Satisfactory server
# is installed to. Since you can bind-mount data volumes for worlds,
# saves or other things, this doesn't really have to change, but is
# here for clarity and customization in case.

ENV SERVER_COMPONENT_NAME=satisfactory
ENV SERVER_HOME=/opt/satisfactory
ENV SERVER_INSTALL_DIR=/opt/satisfactory/satisfactory-dedicatd-server
ENV SERVER_DATA_DIR=/var/opt/satisfactory/data

# Steam still requires 32-bit cross compilation libraries.
RUN echo "=== installing necessary system packages to support steam CLI installation..." \
    && apt-get update \
    && apt-get install -y bash expect htop tmux lib32gcc1 pigz netcat net-tools rsync telnet wget git unzip vim

# Non-privileged user ID.
ENV PROC_UID 7991
ENV PROC_USER satisfactory

RUN echo "=== create a non-privileged user to run with..." \
    && useradd -u ${PROC_UID} -d ${SERVER_HOME} -g nogroup ${PROC_USER}

RUN echo "=== create server directories..." \
    && mkdir -p ${SERVER_HOME} \
    && mkdir -p ${SERVER_INSTALL_DIR} \
    && mkdir -p ${SERVER_DATA_DIR} \
    && mkdir -p ${SERVER_HOME}/Steam \
    && chown -R ${PROC_USER}:nogroup ${SERVER_HOME}

USER ${PROC_USER}

WORKDIR ${SERVER_HOME}

RUN echo "=== downloading and installing steamcmd..." \
    && cd Steam \
    && wget https://media.steampowered.com/installer/steamcmd_linux.tar.gz \
    && tar -zxvf steamcmd_linux.tar.gz \
    && chown -R ${PROC_USER}:nogroup . \
    && cd -

COPY --chown=${PROC_USER}:nogroup scripts/steamcmd-${SERVER_COMPONENT_NAME}.script ${SERVER_HOME}/

# This is most likely going to be the largest layer created; all the game
# files for the dedicated server. NOTE: It is a good idea to do as much as
# possible _beyond_ this point to avoid Docker having to re-create it.
# RUN echo "=== downloading and installing ${SERVER_COMPONENT_NAME} with steamcmd..." \
#     && ${SERVER_HOME}/Steam/steamcmd.sh +runscript ${SERVER_HOME}/steamcmd-${SERVER_COMPONENT_NAME}.script

# Install custom startserver script.
# COPY --chown=${PROC_USER}:nogroup scripts/startserver-1.sh ${SERVER_INSTALL_DIR}/

# Default game ports.
# EXPOSE 2456/tcp 2456/udp
# EXPOSE 2457/tcp 2457/udp
# EXPOSE 2458/tcp 2458/udp

# Install custom entrypoint script.
COPY scripts/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
