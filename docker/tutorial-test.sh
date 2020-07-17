#!/bin/bash -e

working_dir=~/testing

# make working ir
echo started in `pwd`
rm -rf $working_dir
mkdir $working_dir
cd $working_dir

# clean up spack configuration
echo entered `pwd`
rm -rf ~/.spack/*

# clone a new spack
git clone https://github.com/spack/spack
cd spack
git checkout releases/v0.15

# shell init
. share/spack/setup-env.sh
which spack

# run tutorial commands
# For basic usage section
spack install zlib
spack mirror add tutorial /mirror
spack gpg trust /mirror/public.key
spack install zlib %clang
spack install zlib @1.2.8
spack install zlib %gcc@7.5.0
spack install zlib @1.2.8 cppflags=-O3
spack find
spack find -lf
spack install tcl
spack install tcl ^zlib @1.2.8 %clang
spack install tcl ^/64mn
spack find -ldf
spack install hdf5
spack install hdf5~mpi
spack install hdf5+hl+mpi ^mpich
spack find -ldf
spack graph hdf5+hl+mpi ^mpich
spack install trilinos
spack install trilinos +hdf5 ^hdf5+hl+mpi ^mpich
spack find -d trilinos
spack graph trilinos
spack find -d tcl
spack find zlib
spack find -lf zlib
spack find ^mpich
spack find cppflags=-O3
spack find -px
spack install gcc@8.3.0
spack find -p gcc
spack compiler add `spack location -i gcc@8.3.0`
spack compiler remove gcc@8.3.0

# Packagin
spack install mpileaks

# Modules
spack install lmod
source `spack location -i lmod`/lmod/7.8/init/bash
spack compiler add `spack location -i gcc@8.3.0`
spack install netlib-scalapack ^openmpi ^openblas %gcc@8.3.0
spack install netlib-scalapack ^openmpi ^netlib-lapack %gcc@8.3.0
spack install netlib-scalapack ^mpich ^openblas %gcc@8.3.0
spack install netlib-scalapack ^mpich ^netlib-lapack %gcc@8.3.0
spack install py-scipy ^openblas %gcc@8.3.0
spack compiler remove gcc@8.3.0

# Advanced packaging
spack install netlib-lapack
spack install mpich
spack install openmpi
spack install --only=dependencies armadillo ^openblas
spack install --only=dependencies elpa
