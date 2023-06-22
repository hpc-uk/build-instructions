#!/usr/bin/env bash

# You may wish to adjust the WRF version; see "git checkout" below.

# From the default module environemnt
# invoke as "bash ./build-wrf-cray.sh"

set -e

# Install

git clone https://github.com/wrf-model/WRF.git
cd WRF
git checkout release-v4.4.3


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
