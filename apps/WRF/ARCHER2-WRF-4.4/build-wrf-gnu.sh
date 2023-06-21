#!/usr/bin/env bash

# From the default module environemnt
# invoke as "bash ./wrf-build-gcc.sh"

set -e

# Install [uncomment as required]
# Checkout the required release (4.4.3 is known to work)

git clone https://github.com/wrf-model/WRF.git
cd WRF
git checkout release-v4.4.3

module load PrgEnv-gnu
module load cray-hdf5
module load cray-netcdf

module list

# Module cray-netcdf is associated with ${NETCDF_DIR}
# which must be set for the configure stage...

export NETCDF=${NETCDF_DIR}

# The configure option is "34": dmpar for gcc/gfortran
# but we must edit the resulting configure.wrf to replace
# gfortran by ftn etc. "mpicc -cc=$(SCC)" is just replaced
# by "cc"

./configure <<EOF
34
1
EOF

sed -i s/gcc/cc/                     configure.wrf
sed -i s/mpicc\ -cc\$\(SCC\)/cc/     configure.wrf
sed -i s/gfortran/ftn/               configure.wrf
sed -i s/mpif90/ftn/                 configure.wrf

# Compile "em_real" target

./compile -j 8 em_real

module list
