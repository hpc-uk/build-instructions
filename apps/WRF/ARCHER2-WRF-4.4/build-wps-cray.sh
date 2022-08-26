#!/usr/bin/env bash

set -e

export MY_INSTALL=$(pwd)

# Watch out: don't have something with "gcc" here; it will get nuked
# by sed later on...
# The main WRF directory is...

export WRF_DIR=${MY_INSTALL}/WRFV4.4
export JASPER_ROOT=${MY_INSTALL}/grib2

# Install [as required]

wget -O wps-v4.4.tar.gz https://github.com/wrf-model/WPS/archive/refs/tags/v4.4.tar.gz
tar xf wps-v4.4.tar.gz
cd WPS-4.4

./clean

module load cray-hdf5
module load cray-netcdf
module list

# Module cray-netcdf is associated with ${NETCDF_DIR}
# which must be set for the configure stage...

export NETCDF=${NETCDF_DIR}

# JASPER/PNG stuff

export JASPERLIB=${JASPER_ROOT}/lib
export JASPERINC=${JASPER_ROOT}/include

# Cray (dmpar) is "35"

./configure <<EOF
35
EOF

# Compile

./compile

# The make looks like a make -k, so check we have really got three executables
# at the end:

ls -l *exe
