FROM amazonlinux:2
MAINTAINER Spack Maintainers <maintainers@spack.io>

RUN yum update -y \
 && yum groupinstall -y "Development Tools" \
 && yum install -y \
        curl \
        findutils \
        gcc-c++ \
        gcc \
        gcc-gfortran \
        git \
        gnupg2 \
        hostname \
        iproute \
        Lmod \
        make \
        patch \
        python3 \
        python3-pip \
        python3-setuptools \
        tcl \
        unzip \
        vim \
        which \
 && pip3 install boto3 \
 && rm -rf /var/cache/yum \
 && yum clean all

# [WORKAROUND]
# https://superuser.com/questions/1241548/
#     xubuntu-16-04-ttyname-failed-inappropriate-ioctl-for-device#1253889
RUN [ -f ~/.profile ]                                               \
 && sed -i 's/mesg n/( tty -s \\&\\& mesg n || true )/g' ~/.profile \
 || true

