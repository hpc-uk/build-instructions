#!/usr/bin/env bash

set -e

# See https://www.tddft.org/programs/libxc/installation/

export my_prefix=$(pwd)

module load PrgEnv-gnu

# libxc

wget -O libxc-5.2.3.tar.gz http://www.tddft.org/programs/libxc/down.php?file=5.2.3/libxc-5.2.3.tar.gz 
tar xf libxc-5.2.3.tar.gz

cd libxc-5.2.3
CC=cc CXX=CC FC=ftn ./configure --enable-shared --prefix=${my_prefix}
make -j 12
make -j 12 check
make install

cd ${my_prefix}

