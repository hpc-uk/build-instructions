#!/usr/bin/env bash

# Check the WPS version is consistent with the WRF version;
# see "git checkout" below.

# From the default envoronment
# invoke as "bash ./build-wps-cray.sh"

set -e

export MY_INSTALL=$(pwd)

# Watch out: don't have something with "gcc" here; it will get nuked
# by sed later on...
# The main WRF directory is...

export WRF_DIR=${MY_INSTALL}/WRF
export JASPER_ROOT=${MY_INSTALL}/grib2

# Install [comment out "git clone" if not required]
git clone https://github.com/wrf-model/WPS.git
cd WPS
git checkout release-v4.4

# Relevant if there is an existing copy:
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

# Check the make has really generated three executables
ls -l *exe
