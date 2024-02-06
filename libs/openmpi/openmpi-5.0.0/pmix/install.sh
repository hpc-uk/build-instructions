#!/usr/bin/bash

set -e 

source ../setup.sh


PMIX=pmix-$PMIX_VERSION
wget https://github.com/openpmix/openpmix/releases/download/v${PMIX_VERSION}/$PMIX.tar.gz


tar -xvf ${PMIX}.tar.gz 
cd $PMIX
mkdir build
cd build

../configure CFLAGS="-I${HWLOC_ROOT}/include" LDFLAGS="-L${HWLOC_ROOT}/lib" --with-hwloc=${HWLOC_ROOT} --with-libevent=${LIBEVENT_ROOT} --prefix=${PMIX_ROOT}
make 
make install

