#!/usr/bin/env bash

# Build for PrgEnv-gnu

set -e

#tar xf fhi-aims.200112_2.tgz
cd fhi-aims.200112_2
export FHI_AIMS_ROOT=`pwd`

mkdir build-gnu
cd build-gnu

module swap PrgEnv-cray PrgEnv-gnu
module load cmake

cat >> initial_cache.cmake << EOF
set(CMAKE_Fortran_COMPILER ftn CACHE STRING "")
set(CMAKE_Fortran_FLAGS "-O3 -ffree-line-length-none" CACHE STRING "")
set(Fortran_MIN_FLAGS "-O0 -ffree-line-length-none" CACHE STRING "")
set(CMAKE_C_COMPILER cc CACHE STRING "")
set(CMAKE_C_FLAGS "-O3" CACHE STRING "")
EOF

cmake -C initial_cache.cmake ..
make -j 6

