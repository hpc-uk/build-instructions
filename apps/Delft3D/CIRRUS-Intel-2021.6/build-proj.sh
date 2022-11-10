#!/usr/bin/env bash

set -e

module load oneapi
module load compiler/latest
module load gcc

module list

export prefix=$(pwd)/install

# 5.4.0 does not pass tests.
# Use 6.3.1

version=6.3.1
wget https://download.osgeo.org/proj/proj-${version}.tar.gz
tar -xf proj-${version}.tar.gz
cd proj-${version}

# We prefer the autotools method as this will produce a proj.pc file,
# which is needed for delft3d (cmake does not)

./configure CC=icc CXX=icpc --prefix=${prefix}/proj

make -j 6
make -j 2 check
make install

