#!/usr/bin/env bash

# From the default module environemnt
# invoke as "bash ./wrf-build-gcc.sh"

set -e

# Install [uncomment as required]
wget https://github.com/wrf-model/WRF/archive/v4.2.1.tar.gz
tar zxf v4.2.1.tar.gz
cd WRF-4.2.1

module -s restore PrgEnv-gnu
module swap gcc gcc/9.3.0
module load cray-hdf5
module load cray-netcdf
module list

# Module cray-netcdf is associated with ${NETCDF_DIR}
# which must be set for the configure stage...

export WRF_CHEM=1
export WRF_KPP=1
export NETCDF=${NETCDF_DIR}

FLEX_VERSION='2.6.4'
export FLEX_LIB_DIR=$(pwd)/../flex-${FLEX_VERSION}/lib/

YACC_VERSION='20210109'
export YACC_PATH=$(pwd)/../byacc-${YACC_VERSION}/bin/


# The configure option is "34": dmpar for gcc/gfortran
# but we must edit the resulting configure.wrf to replace
# gfortran by ftn etc.

./configure <<EOF
34
1
EOF

sed -i s/gcc/cc/       configure.wrf
sed -i s/mpicc/cc/     configure.wrf
sed -i s/gfortran/ftn/ configure.wrf
sed -i s/mpif90/ftn/   configure.wrf

sed -i 's/-ll //'  chem/KPP/kpp/kpp-2.1/src/Makefile

sed -i 's/#  YACC=/YACC=${YACC_PATH}\//' chem/KPP/configure_kpp

# Compile "em_real" target

./compile -j 8 em_real
