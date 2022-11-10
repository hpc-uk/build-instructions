#!/usr/bin/env bash

set -e

module load libtool
module load oneapi
module load compiler/latest
module load gcc

module list

# GDAL is from OSGeo and depends on a number of packages in
# the install location (see configure step)

export prefix=$(pwd)/install
export gdal=${prefix}/gdal

v=2.4.4
wget https://github.com/OSGeo/gdal/releases/download/v${v}/gdal-${v}.tar.gz
tar -xf gdal-${v}.tar.gz
cd gdal-${v}

# Python is problematic so leave it out at the moment.

export LD_LIBRARY_PATH=${prefix}/proj/lib64:${LD_LIBRARY_PATH}

./configure CC=icc CXX=icpc FC=ifort CFLAGS="-g -O2" CPPFLAGS="-g -O2" \
	    --without-jasper \
	    --with-expat=${prefix}/expat \
	    --with-proj=${prefix}/proj \
	    --with-hdf5=${prefix}/hdf5 \
	    --with-netcdf=${prefix}/netcdf \
	    --prefix=${gdal}

make -j 8
make install
