#!/usr/bin/env bash

set -e

# Install

wget https://github.com/wrf-model/WRF/releases/download/v4.4/v4.4.tar.gz
tar xf v4.4.tar.gz
cd WRFV4.4

module load PrgEnv-gnu
module load cray-hdf5
module load cray-netcdf
module list

# Module cray-netcdf is associated with ${NETCDF_DIR}
# which must be set for the configure stage...
# NETCDF4 support not available, use classic...

export NETCDF=${NETCDF_DIR}
export NETCDF_classic=1

# The configure option is "34": dmpar for gcc/gfortran.
# The "1" is for basic nesting (the default).

# We must edit the resulting configure.wrf to replace
# gfortran by ftn etc. 

./configure <<EOF
34
1
EOF


sed -i s/gcc/cc/       configure.wrf
sed -i s/mpicc/cc/     configure.wrf
sed -i s/gfortran/ftn/ configure.wrf
sed -i s/mpif90/ftn/   configure.wrf

# Compile "em_real" target

./compile -j 8 em_real
