FROM ubuntu:18.04

ARG REMOTE_BUILDCACHE_URL="tutorial s3://spack-binaries-prs/tutorial/ecp21/mirror"

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        autoconf \
        build-essential \
        ca-certificates \
        curl \
        clang \
        emacs \
        file \
        g++ \
        g++-6 \
        gcc \
        gcc-6 \
        gfortran \
        gfortran-6 \
        git \
        gnupg2 \
        iproute2 \
        make \
        openssh-server \
        python3 \
        python3-pip \
        tcl \
        unzip \
        vim \
        wget && \
    python3 -m pip install --upgrade pip setuptools wheel && \
    python3 -m pip install --upgrade gnureadline && \
    python3 -m pip install --upgrade awscli && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && \
    apt-get autoremove --purge && \
    apt-get clean

COPY /packages.yaml /etc/spack/packages.yaml
COPY /config.yaml /etc/spack/config.yaml
COPY /tutorial-test.sh /tutorial/.test/tutorial-test.sh

RUN useradd -ms /bin/bash spack && \
    mkdir -p /mirror/build_cache && \
    aws s3 sync ${REMOTE_BUILDCACHE_URL} /mirror && \
    chmod -R go+r /mirror && \
    chmod -R go+r /etc/spack && \
    chmod go+rx /tutorial/.test/tutorial-test.sh

USER spack

WORKDIR /home/spack

CMD ["bash"]
