FROM        buildbot/buildbot-worker:v2.10.0
MAINTAINER  alicef@gentoo.org

USER root

# This will make apt-get install without question
ARG DEBIAN_FRONTEND=noninteractive

# Install required packages and updates
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y dist-upgrade && \
    apt-get -y install -q \
    python3 \
    build-essential \
    libtool \
    python3-pip \
    libelf-dev \
    bc \
    docker.io \
    bison \
    flex \
    vim \
    autoconf \
    && rm -rf /var/lib/apt/lists/*

# Install python required packages
RUN pip3 install --upgrade pip
RUN pip3 install virtualenv
RUN pip3 install lavacli
RUN pip3 install beautifulsoup4
RUN pip3 install lxml
RUN pip3 install jsonschema
RUN pip3 install pyyaml
RUN pip3 install python-dateutil
RUN pip3 install jq
RUN pip3 install --user --use-deprecated=legacy-resolver git+https://github.com/kernelci/kcidb.git@v8

# Create fileserver folder for passing files to lava
RUN mkdir -p /var/www/fileserver
RUN chown -R buildbot /var/www/fileserver

USER root
WORKDIR /buildbot

# Add kcidb configuration (if you are not sending to kernelci just comment out this)
COPY .kernelci-ci-gkernelci.json /home/buildbot/.kernelci-ci-gkernelci.json
ARG GOOGLE_APPLICATION_CREDENTIALS=~/.kernelci-ci-gkernelci.json

# Getting lava settings from docker-compose.yml
ARG LAVA_TOKEN
ARG LAVA_USER
ARG LAVA_SERVER

RUN mkdir -p ~/.config/
RUN printf 'buildbot:\n  uri: http://$LAVA_USER:$LAVA_TOKEN@$LAVA_SERVER/RPC2' > ~/.config/lavacli.yaml
RUN lavacli identities add --uri http://$LAVA_USER:$LAVA_TOKEN@$LAVA_SERVER/RPC2 buildbot
