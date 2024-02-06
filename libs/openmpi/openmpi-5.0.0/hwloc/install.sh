#!/usr/bin/bash

source ../setup.sh

wget https://download.open-mpi.org/release/hwloc/v2.9/hwloc-$HWLOC_VERSION.tar.gz .

tar xvf hwloc-$HWLOC_VERSION.tar.gz


cd hwloc-$HWLOC_VERSION
mkdir build
cd build

../configure --prefix=${HWLOC_ROOT}
make 
make install
