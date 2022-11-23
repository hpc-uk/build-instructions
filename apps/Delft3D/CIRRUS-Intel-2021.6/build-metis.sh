#!/usr/bin/env bash

set -e

module load cmake/3.22.1
module load oneapi
module load compiler/latest
module load gcc

module list

export prefix=$(pwd)/install

# Metis

VERSION=5.1.0

wget http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-${VERSION}.tar.gz
tar xf metis-${VERSION}.tar.gz

cd metis-${VERSION}

make config prefix=${prefix}/metis cc=icc shared=1
make
make install

