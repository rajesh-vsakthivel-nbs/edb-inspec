FROM ubuntu:23.04
LABEL maintainer="Chef Software, Inc. <docker@chef.io>"

ARG VERSION=5.22.3
ARG CHANNEL=stable

ENV PATH=/opt/inspec/bin:/opt/inspec/embedded/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Upgrade installed packages
RUN apt-get update && apt-get upgrade -y && apt-get clean

# Python package management and basic dependencies
RUN apt-get install -y curl


RUN apt-get update && \
      apt-get -y install sudo






# Run the entire container with the default locale to be en_US.UTF-8
RUN apt-get update && \
    apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8


RUN mkdir -p /share

RUN apt-get update && \
    apt-get install -y wget rpm2cpio cpio && \
    wget "http://packages.chef.io/files/${CHANNEL}/inspec/${VERSION}/el/7/inspec-${VERSION}-1.el7.x86_64.rpm" -O /tmp/inspec.rpm && \
    rpm2cpio /tmp/inspec.rpm | cpio -idmv && \
    rm -rf /tmp/inspec.rpm

# Install any packages that make life easier for an InSpec installation
RUN apt-get install -y git

RUN mkdir -p /etc/chef/accepted_licenses
COPY inspec-accepted-license /etc/chef/accepted_licenses/inspec
COPY /kube /root/.kube
COPY /aws /root/.aws
COPY /login /share



RUN    gem install kubernetes-cli -v 0.3.2  && \
    gem install kubectl -v 1.6.4


#install node and npm
RUN apt-get update && \
    apt-get -y install curl && \
    apt-get -y install build-essential
RUN apt-get update
RUN apt-get -y install curl gnupg
RUN apt-get -y install nodejs npm

RUN apt update  
RUN apt upgrade 
RUN sudo apt install -y \
      python3-dev \
      python3-pip \
      python3-venv \
      python3-virtualenv

RUN apt install -y pipx

RUN pipx ensurepath
RUN pipx install awsume



RUN apt-get install -y p7zip \
    p7zip-full \
    unace \
    zip \
    unzip \
    xz-utils \
    sharutils \
    uudeview \
    mpack \
    arj \
    cabextract \
    file-roller \
    && rm -rf /var/lib/apt/lists/*

#install and set-up aws-cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
unzip awscliv2.zip && \
 ./aws/install

WORKDIR /share
RUN sudo npm install -g aws-azure-login --unsafe-perm
RUN sudo chmod -R go+rx $(npm root -g)


# We don't need the standalone Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Install Google Chrome Stable and fonts
# Note: this installs the necessary libs to make the browser work with Puppeteer.
RUN apt-get update && apt-get install gnupg wget -y && \
  wget --quiet --output-document=- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/google-archive.gpg && \
  sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
  apt-get update && \
  apt-get install google-chrome-stable -y --no-install-recommends && \
  rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["inspec"]

CMD /bin/bash
VOLUME ["/share"]
