#!/usr/bin/env bash


set -e

# Install [uncomment as required]
wget -O wrf-v4.4.tar.gz https://github.com/wrf-model/WRF/releases/download/v4.4/v4.4.tar.gz 
tar xf wrf-v4.4.tar.gz
cd WRFV4.4

module load cray-hdf5
module load cray-netcdf
module list

# Module cray-netcdf is associated with ${NETCDF_DIR}
# which must be set for the configure stage...
# NETCDF4 support not available, use classic...

export NETCDF=${NETCDF_DIR}
export NETCDF_classic=1


# Cray (dmpar) is "46"; "1" is for basic nesting.

./configure <<EOF
46
1
EOF

# Compile "em_real" target
# Compilation can take an inordinately long time (cf. PrgEnv-gnu)

./compile -j 8 em_real
