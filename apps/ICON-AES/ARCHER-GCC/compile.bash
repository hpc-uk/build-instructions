#!/bin/bash

. ./modules.bash
module list &> compile_module_list.out

export FC=ftn
export CXX=CC
export CC=cc
make clean &> clean.out
make distclean &> distclean.out
./configure &> configure.out
make -j 8 &> make.out
