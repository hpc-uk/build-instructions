#!/usr/bin/env bash

# From the default envoronment
# invoke as "bash ./jasper-build-gnu.sh"

set -e

MY_INSTALL=$(pwd)/grib2

# See https://www.ece.uvic.ca/~frodo/jasper/

# Install [as required]
# I've preferred this download version over any from github as it does
# not require the autoconf stage
# nb. Later versions, e.g., 1.900.28, may fail to compile.

wget https://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.1.zip
unzip jasper-1.900.1.zip
cd jasper-1.900.1

module load PrgEnv-gnu
module load cray-hdf5
module load cray-netcdf
module list

./configure --prefix=${MY_INSTALL}
make -j 4
make install

