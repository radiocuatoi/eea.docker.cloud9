FROM node:alpine
MAINTAINER "radiocuatoi" <radiocuatoi@gmail.com>

# ------------------------------------------------------------------------------
# Install dependencies
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential git pylint python3-dev python3-pip openssh-server \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 
RUN pip-3.2 install virtualenv \
 && pip-3.2 install chaperone \
 && mkdir /etc/chaperone.d /cloud9 /var/run/sshd

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
# Set default workspace dir
ENV C9_WORKSPACE /cloud9/workspace
ENV AUTHORIZED_KEYS **None**

# ------------------------------------------------------------------------------
# Configuration
COPY conf/chaperone.conf /etc/chaperone.d/chaperone.conf
ADD sshd.sh /sshd.sh

# ------------------------------------------------------------------------------
# Expose ports.
EXPOSE 8080 22

# ------------------------------------------------------------------------------
# Start
ENTRYPOINT ["/usr/local/bin/chaperone"]
