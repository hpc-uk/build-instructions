#!/usr/bin/env bash

set -e

module load cmake/3.22.1
module load oneapi
module load compiler/latest
module load gcc

module list

export prefix=$(pwd)/install

wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.21/src/hdf5-1.8.21.tar.gz
tar xf hdf5-1.8.21.tar.gz
cd hdf5-1.8.21

./configure CC=icc CXX=icpc FC=ifort --prefix=${prefix}/hdf5 \
  --enable-shared --enable-hl --enable-fortran

make -j 16
make check
make install
