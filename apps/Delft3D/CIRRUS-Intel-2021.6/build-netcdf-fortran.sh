#!/usr/bin/env bash

set -e

module load oneapi
module load compiler/latest
module load gcc

module list

# NetCDF depends on HDF5.
# Note the install location is the same as netcdf.

export prefix=$(pwd)/install
export hdf5=${prefix}/hdf5
export netcdf=${prefix}/netcdf
export fortran="${netcdf}-fortran"

version=4.6.0
wget https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v${version}.tar.gz
tar -xf v${version}.tar.gz
cd netcdf-fortran-${version}

export LD_LIBRARY_PATH=${netcdf}/lib:${LD_LIBRARY_PATH}

./configure CC=icc CXX=icpc FC=ifort \
	    CPPFLAGS="-I ${hdf5}/include -I${netcdf}/include" \
	    LDFLAGS="-L${hdf5}/lib -L${netcdf}/lib" \
  --prefix=${prefix}/netcdf

make -j 16
make check
make install
