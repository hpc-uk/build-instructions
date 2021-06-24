#!/usr/bin/env bash

# From the default envoronment
# invoke as "bash ./build-wps-cray.sh"

set -e

export MY_INSTALL=`pwd`

# Watch out: don't have something with "gcc" here; it will get nuked
# by sed later on...
# The main WRF directory is...

export WRF_DIR=${MY_INSTALL}/WRF-4.2.1
export JASPER_ROOT=${MY_INSTALL}/grib2

# Install [as required]
wget https://github.com/wrf-model/WPS/archive/v4.2.tar.gz
tar zxf v4.2.tar.gz
cd WPS-4.2

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
