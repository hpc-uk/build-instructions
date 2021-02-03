#!/usr/bin/env bash

# From the default module environemnt
# invoke as "bash ./build-wrf-cray.sh"

set -e

# Install [uncomment as required]
wget https://github.com/wrf-model/WRF/archive/v4.2.1.tar.gz
tar zxf v4.2.1.tar.gz
cd WRF-4.2.1

module load cray-hdf5
module load cray-netcdf
module list

# Module cray-netcdf is associated with ${NETCDF_DIR}
# which must be set for the configure stage...

export NETCDF=${NETCDF_DIR}

# Cray (dmpar) is "46"; "1" is for basic nesting.

./configure <<EOF
46
1
EOF

# Compile "em_real" target
# Compilation can take an inordinately long time (cf. PrgEnv-gnu)

./compile -j 8 em_real
