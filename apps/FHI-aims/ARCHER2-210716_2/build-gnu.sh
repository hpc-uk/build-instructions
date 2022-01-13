#!/usr/bin/env bash

set -e

module load PrgEnv-gnu

#tar xf fhi-aims.200112_2.tgz
cd fhi-aims.210716_2
export FHI_AIMS_ROOT=`pwd`

mkdir _build-gnu
cd _build-gnu

cat >> initial_cache.cmake << EOF
set(CMAKE_Fortran_COMPILER ftn CACHE STRING "")
set(CMAKE_Fortran_FLAGS "-O2 -fallow-argument-mismatch -ffree-line-length-none" CACHE STRING "")
set(Fortran_MIN_FLAGS "-O0 -fallow-argument-mismatch -ffree-line-length-none" CACHE STRING "")
set(CMAKE_C_COMPILER cc CACHE STRING "")
set(CMAKE_C_FLAGS "-O2" CACHE STRING "")
EOF

cmake -C initial_cache.cmake ..
make -j 16
