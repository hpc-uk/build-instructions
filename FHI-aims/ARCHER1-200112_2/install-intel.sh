#!/usr/bin/env bash

set -e

tar xf fhi-aims.200112_2.tgz
cd fhi-aims.200112_2
export FHI_AIMS_ROOT=`pwd`

mkdir build-intel
cd build-intel

module swap PrgEnv-cray PrgEnv-intel
module swap intel intel/17.0.3.191
module swap gcc gcc/6.3.0
module load cmake
module load cray-libsci

cat >> initial_cache.cmake << EOF
set(CMAKE_Fortran_COMPILER ftn CACHE STRING "")
set(CMAKE_Fortran_FLAGS "-O3 -ip -fp-model precise" CACHE STRING "")
set(Fortran_MIN_FLAGS "-O0 -ip -fp-model precise" CACHE STRING "")
set(CMAKE_C_COMPILER cc CACHE STRING "")
set(CMAKE_C_FLAGS "-O3 -ip -fp-model precise" CACHE STRING "")
EOF

cmake -C initial_cache.cmake ..
make -j 6

