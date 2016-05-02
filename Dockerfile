FROM node:0.12-slim
MAINTAINER "EEA: IDM2 A-Team" <eea-edw-a-team-alerts@googlegroups.com>

# ------------------------------------------------------------------------------
# Install dependencies
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential git pylint virtualenv python3-dev python3-pip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && pip3 install chaperone \
 && mkdir /etc/chaperone.d /cloud9

# ------------------------------------------------------------------------------
# Get cloud9 source and install
WORKDIR /cloud9
RUN git clone https://github.com/c9/core.git . \
 && scripts/install-sdk.sh \
 && sed -i -e 's_127.0.0.1_0.0.0.0_g' configs/standalone.js \
 && sed -i -e 's_message: "-d all -e E -e F",_message: "-d all -e E,F,W",_g' plugins/c9.ide.language.python/python.js \
 && mkdir workspace

# ------------------------------------------------------------------------------
# Add workspace volumes
VOLUME /cloud9/workspace

# ------------------------------------------------------------------------------
# Configuration
COPY conf/chaperone.conf /etc/chaperone.d/chaperone.conf

# ------------------------------------------------------------------------------
# Expose ports.
EXPOSE 8080

# ------------------------------------------------------------------------------
# Start
ENTRYPOINT ["/usr/local/bin/chaperone"]