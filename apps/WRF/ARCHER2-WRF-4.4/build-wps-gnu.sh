#!/usr/bin/env bash

set -e

export MY_INSTALL=$(pwd)

# The main WRF directory is...

export WRF_DIR=${MY_INSTALL}/WRFV4.4
export JASPER_ROOT=${MY_INSTALL}/grib2

# Download

wget -O wps-v4.4.tar.gz https://github.com/wrf-model/WPS/archive/refs/tags/v4.4.tar.gz
tar xf wps-v4.4.tar.gz
cd WPS-4.4


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
