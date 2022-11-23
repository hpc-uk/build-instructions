#!/usr/bin/env bash

set -e

module load libtool
module load oneapi
module load compiler/latest
module load gcc

module list

# Depends on proj

export prefix=$(pwd)/install
export proj=${prefix}/proj

git clone https://github.com/OSGeo/shapelib.git
cd shapelib

./autogen.sh
./configure CC=icc CXX=icpc \
	    CFLAGS="-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H" \
	    CPPFLAGS="-I ${proj}/include" LDFLAGS="-L${proj}/lib" \
	    --prefix=${prefix}/shapelib

make -j 4
make check
make install
