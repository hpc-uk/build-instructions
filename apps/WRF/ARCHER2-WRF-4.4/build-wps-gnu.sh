#!/usr/bin/env bash

# Make sure the version is consistent with WRF.
# See "git checkout" below.

# From the default environment
# invoke as "bash ./wps-build-gnu.sh"

set -e

export MY_INSTALL=$(pwd)

# Watch out: don't have something with "gcc" here; it will get nuked
# by sed later on...
# The main WRF directory is...

export WRF_DIR=${MY_INSTALL}/WRF
export JASPER_ROOT=${MY_INSTALL}/grib2

# Install [as required]

git clone https://github.com/wrf-model/WPS.git
cd WPS
git checkout release-v4.4

# Relevant if there is an existing copy.
./clean

module load PrgEnv-gnu
module load cray-hdf5
module load cray-netcdf

# Module cray-netcdf is associated with ${NETCDF_DIR}
# which must be set for the configure stage...

export NETCDF=${NETCDF_DIR}

# JASPER/PNG stuff

export JASPERLIB=${JASPER_ROOT}/lib
export JASPERINC=${JASPER_ROOT}/include

# The configuration selection is "3" for gcc/gfortran
# but we must again edit the resultant configure.wps to
# replace gfortran by ftn etc.

./configure <<EOF
3
EOF

sed -i s/gcc/cc/       configure.wps
sed -i s/mpicc/cc/     configure.wps
sed -i s/gfortran/ftn/ configure.wps
sed -i s/mpif90/ftn/   configure.wps

# Compile

./compile

# The make looks like a make -k, so check we have really got three executables
# at the end:

ls -l *exe
