#!/usr/bin/env bash

# Assumes you have the tar bundle fhi-aims.240920.tgz and this script
# in the current directory. Must be in /work. 

# Invoke with e.g., "bash ./install-intel.sh" 

set -e

tar -xvf fhi-aims.240920.tgz 
cd fhi-aims.240920 
mkdir build-intel 
cd build-intel 

export FHI_AIMS_ROOT=`pwd`
module load intel-20.4/compilers
module load intel-20.4/mpi
module load intel-20.4/fc
module load intel-20.4/cmkl
module load cmake 

sed -i 's/error stop error%message/error stop/g' ../external_libraries/toml-f/src/tomlf/ser.f90

cat >> initial_cache.cmake <<EOF
 set(CMAKE_Fortran_COMPILER mpiifort CACHE STRING "")
set(CMAKE_Fortran_FLAGS "-O3 -ip -fp-model precise" CACHE STRING "")
set(Fortran_MIN_FLAGS "-O0 -ip -fp-model precise" CACHE STRING "")
set(CMAKE_C_COMPILER mpiicc CACHE STRING "")
set(CMAKE_CXX_COMPILER mpiicpc CACHE STRING "")
set(CMAKE_C_FLAGS "-O3 -ip -fp-model precise" CACHE STRING "")
set(USE_SCALAPACK true CACHE BOOL "Use SCALAPACK")
set(CMAKE_EXE_LINKER_FLAGS "-L${MKLROOT}/lib/intel64 -lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lmkl_blacs_intelmpi_lp64 -lpthread -lm -ldl" CACHE STRING "")
EOF

cmake -C initial_cache.cmake ..
make -j 8 
