#!/usr/bin/env bash

set -e

tar xf fhi-aims.210716_2.tgz
cd fhi-aims.210716_2

export FHI_AIMS_ROOT=`pwd`

mkdir _build-cray
cd _build-cray

# Use at least cce >= 12.0.3

module load PrgEnv-cray
module load cce/12.0.3

cat >> initial_cache.cmake << EOF
set(CMAKE_Fortran_COMPILER ftn CACHE STRING "")
set(CMAKE_Fortran_FLAGS "-O2" CACHE STRING "")
set(Fortran_MIN_FLAGS "-O0" CACHE STRING "")
set(CMAKE_C_COMPILER cc CACHE STRING "")
set(CMAKE_C_FLAGS "-O2" CACHE STRING "")
EOF

cmake -C initial_cache.cmake ..
make -j 16
