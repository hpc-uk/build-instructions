#!/usr/bin/env bash

set -e

module load libtool
module load oneapi
module load compiler/latest
module load gcc

module list

export prefix=$(pwd)/install

git clone https://github.com/libexpat/libexpat.git
cd libexpat
cd expat/
./buildconf.sh

./configure CC=icc CXX=icpc --prefix=${prefix}/expat

make
make check
make install
