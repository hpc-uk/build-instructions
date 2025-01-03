#!/usr/bin/env bash

#SBATCH --partition=standard
#SBATCH --qos=standard

#SBATCH --time=03:00:00

#SBATCH --export=none
#SBATCH --exclusive

set -e

printf "Start at: %s\n" "$(date)"

# ESMF
# See e.g.,
# https://earthsystemmodeling.org/docs/release/latest/ESMF_usrdoc/
# for which "latest" is v8.7.0 at the time of writing.
#
# Here, we want 8.6.1.

version=8.6.1
rules=$(pwd)/Unicos.gfortran.default.build_rules.mk

printf "Version %s\n" "${version}"
printf "Rules   %s\n" "${rules}"
ls -l ${rules}

# Install prefix
prefix="$(pwd)/ESMF/${version}"

# Prefer tar route as the .gitignore has a very large number of entries
# which make it problematic to see if there are build artefacts
# present at any given stage.
#
# wget https://github.com/esmf-org/esmf/archive/refs/tags/v8.6.1.tar.gz
#
# The equivalent git route is
# git clone https://github.com/esmf-org/esmf.git
# git checkout v8.6.1

tar xf v${version}.tar.gz
cd esmf-${version}

cp ${rules} build_config/Unicos.gfortran.default/build_rules.mk

export ESMF_DIR=$(pwd)

module load PrgEnv-gnu
module load cray-hdf5-parallel
module load cray-netcdf-hdf5parallel
module load cray-parallel-netcdf

# Many environments variable are set by choice of ESMF_COMPILER via, e.g.,
# build_config/Unicos/gfortran.default/build_rules.mk

# Don't read too much into these names, "Unicos.gfortran.default" happens
# to be available, and has appropriate options. "mpi" may be read as
# "mpich". We use the compiler wrappers cc, CC, ftn.

export ESMF_OS="Unicos"
export ESMF_ABI="64"
export ESMF_COMM="mpi"
export ESMF_COMM="mpich"
export ESMF_COMPILER="gfortran"
export ESMF_BOPT="O"
export ESMF_OPTLEVEL="2"

# Note that "nc-config" does not seem to pick up the relevant options,
# as we are bypassing the compiler wrappers. Hence explicit set of
# NETCDF locations

export ESMF_LAPACK="system"
export ESMF_NETCDF="nc-config"
export ESMF_PNETCDF="pnetcdf-config"

# A problem may arise if trying to link Fortran objects containing Fortran
# NetCDF calls using CC as the linker. The appropriate Fortran -lnetcdff
# doesn't get added. And "nc-config --libs" does not have it. So add
# explicitly ...

export ESMF_NETCDF_LIBS="-lnetcdf -lnetcdff"

export ESMF_TESTEXHAUSTIVE=ON
export ESMF_INSTALL_PREFIX=${prefix}


make info |& tee -a make-info-gfortran.log

make -j 8 |& tee -a make-make-gfortran.log

# The following tests must be serialised (i.e., "make -j 1"); otherwise they
# may interfere with each other and fail...

make unit_tests_uni
make unit_tests

make system_tests_uni
make system_tests

make examples

# Install

make install

module list

printf "Start at: %s\n" "$(date)"
