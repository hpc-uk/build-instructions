#!usr/bin/env bash

# Assumes you have the tar bundle fhi-aims.200112_2.tgz and this script
# in the current directory.

# Invoke with e.g., "bash ./install-intel.sh"

set -e

tar xf fhi-aims.200112_2.tgz
cd fhi-aims.200112_2
export FHI_AIMS_ROOT=`pwd`

mkdir build-intel
cd build-intel

module load intel-mpi-18
module load intel-compilers-18
module load intel-tools-18

module load cmake

cat >> initial_cache.cmake <<EOF
 set(CMAKE_Fortran_COMPILER mpiifort CACHE STRING "")
set(CMAKE_Fortran_FLAGS "-O3 -ip -fp-model precise" CACHE STRING "")
set(Fortran_MIN_FLAGS "-O0 -ip -fp-model precise" CACHE STRING "")
set(CMAKE_C_COMPILER mpiicc CACHE STRING "")
set(CMAKE_C_FLAGS "-O3 -ip -fp-model precise" CACHE STRING "")
set(CMAKE_CXX_COMPILER mpiicpc CACHE STRING "")
set(USE_SCALAPACK true CACHE BOOL "Use SCALAPACK")
set(CMAKE_EXE_LINKER_FLAGS "-L${MKLROOT}/lib/intel64 -lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lmkl_blacs_intelmpi_lp64 -lpthread -lm -ldl" CACHE STRING "")
EOF


cmake -C initial_cache.cmake ..

make -j 8
