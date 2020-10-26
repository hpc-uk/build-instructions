#!usr/bin/env bash

# Assumes you have the tar bundle fhi-aims.200112_2.tgz and this script
# in the current directory.

# Invoke with e.g., "bash ./install-gnu.sh"

set -e

tar xf fhi-aims.200112_2.tgz
cd fhi-aims.200112_2
export FHI_AIMS_ROOT=`pwd`

mkdir build-gnu
cd build-gnu

# Scalapack is from intel-tools-19
# See https://cirrus.readthedocs.io/en/master/software-libraries/intel_mkl.html

module load mpt/2.22
module load gcc/6.3.0
module load intel-tools-19

module load cmake

cat >> initial_cache.cmake <<EOF
set(CMAKE_Fortran_COMPILER mpif90 CACHE STRING "")
set(CMAKE_Fortran_FLAGS "-f90=gfortran -O3 -ffree-line-length-none" CACHE STRING "")
set(Fortran_MIN_FLAGS "-f90=gfortran -O0 -ffree-line-length-none" CACHE STRING "")
set(CMAKE_C_COMPILER mpicc CACHE STRING "")
set(CMAKE_C_FLAGS "-O3" CACHE STRING "")
set(USE_SCALAPACK true CACHE BOOL "Use SCALAPACK")
set(CMAKE_EXE_LINKER_FLAGS "-L${MKLROOT}/lib/intel64 -lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lmkl_blacs_sgimpt_lp64 -lpthread -lm -ldl" CACHE STRING "")
EOF

cmake -C initial_cache.cmake ..

make -j 8
