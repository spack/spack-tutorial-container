FROM ubuntu:16.04

RUN mkdir /mirror
COPY build_cache /mirror/build_cache
COPY public.key  /mirror/public.key

#COPY sc-tutorial-sysconfig/packages.yaml  /etc/spack/packages.yaml

#RUN chmod -R go+r /etc/spack
RUN chmod -R go+r /mirror

RUN apt-get -yqq update && apt-get -yqq install ca-certificates
RUN apt-get -yqq update                                   \
 && apt-get -yqq install                                  \
        ca-certificates curl       g++    \
        gcc-4.7           g++-4.7       gfortran-4.7        \
        gcc             gfortran        git        gnupg2 \
        iproute2        make   \
        openssh-server  python          python-pip tcl    \
        clang           clang-3.7       emacs      unzip  \
        autoconf

# copy in scripts to test container
COPY tutorial-test.sh /tutorial/.test/tutorial-test.sh
RUN chmod -R go+rx /tutorial/.test/tutorial-test.sh

RUN useradd -ms /bin/bash spack
USER spack
WORKDIR /home/spack

CMD ["bash"]
