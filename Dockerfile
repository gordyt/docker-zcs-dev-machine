FROM ubuntu:16.04

# Install Basic Packages
RUN apt-get update && \
    apt-get install -y \
    ant \
    ant-contrib \
    build-essential \
    curl \
    dnsmasq \
    dnsutils \
    gettext \
    git \
    git-flow \
    linux-tools-common \
    maven \
    net-tools \
    npm \
    openjdk-8-jdk \
    python \
    python-pip \
    ruby \
    rsyslog \
    software-properties-common \
    vim \
    wget

# Trick build into skipping resolvconf as docker overrides for DNS
# This is currently required by our installer script. Hopefully be
# fixed soone.
RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections

RUN mkdir -p /tmp/release && \
    curl -s -k -o /tmp/zcs.tgz 'https://files.zimbra.com.s3.amazonaws.com/downloads/8.8.1_GA/zcs-8.8.1_GA_1782.UBUNTU16_64.20170726140343.tgz' && \
    tar xzvf /tmp/zcs.tgz -C /tmp/release --strip-components=1 && \
    rm /tmp/zcs.tgz

COPY ./software-install-responses /tmp/software-install-responses

WORKDIR /tmp/release

RUN sed -i.bak 's/checkRequired/# checkRequired/' install.sh && \
    ./install.sh -s -x --skip-upgrade-check < /tmp/software-install-responses

WORKDIR /tmp
RUN rm -rf /tmp/release

EXPOSE 22 25 80 110 143 443 465 587 993 995 7071 8443
