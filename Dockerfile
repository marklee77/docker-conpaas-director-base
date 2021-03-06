FROM harnesscloud/debian-cloudimage:latest
MAINTAINER Mark Stillwell <mark@stillwell.me>

# install dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -y install \
        apache2 \
        autoconf-archive \
        automake \
        build-essential \
        default-jdk \
        git \
        libapache2-mod-php5 \
        libapache2-mod-wsgi \
        libcurl4-openssl-dev \
        libffi-dev \
        php5-curl \
        python \
        python-dev \
        python-httplib2 \
        python-pip \
        python-openssl \
        python-pycurl \
        python-setuptools \
        python-simplejson \
        sqlite3 && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN pip install argcomplete
