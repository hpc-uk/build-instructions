#!/usr/bin/env bash

# From the default envoronment
# invoke as "bash ./libpng-build-gnu.sh"

set -e

export MY_INSTALL=`pwd`/grib2

# Install [as required]

wget -O libpng-1.6.37.tar.xz https://sourceforge.net/projects/libpng/files/libpng16/1.6.37/libpng-1.6.37.tar.xz/download
tar xf libpng-1.6.37.tar.xz
cd libpng-1.6.37


module -s restore PrgEnv-gnu
module swap gcc gcc/9.3.0
module load cray-hdf5
module load cray-netcdf
module list

./configure --prefix=${MY_INSTALL}
make -j 4
make install

