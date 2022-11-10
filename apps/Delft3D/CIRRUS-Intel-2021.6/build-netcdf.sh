#!/usr/bin/env bash

set -e

module load cmake/3.22.1
module load oneapi
module load compiler/latest
module load gcc

module list

# NetCDF depends on HDF5.

export prefix=$(pwd)/install
export hdf5=${prefix}/hdf5

version=4.9.0
wget https://github.com/Unidata/netcdf-c/archive/refs/tags/v${version}.tar.gz
tar -xf v${version}.tar.gz
cd netcdf-c-${version}

# May want to remove "--enable-shared" as may cause problems finding
# shared objects later (e.g., for netcdf-fortran).

./configure CC=icc CXX=icpc FC=ifort \
  CPPFLAGS="-I ${hdf5}/include" LDFLAGS="-L${hdf5}/lib" \
  --prefix=${prefix}/netcdf \
  --enable-dap --enable-netcdf-4 --enable-shared

make -j 16
make check
make install
