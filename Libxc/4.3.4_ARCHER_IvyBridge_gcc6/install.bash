#!/bin/bash
module switch PrgEnv-$(echo $PE_ENV | tr '[:upper:]' '[:lower:]') PrgEnv-gnu 

export CC=cc
export FC=ftn
export CRAYPE_LINK_TYPE=dynamic
# The prefix will be something like
# /work/y07/y07/cse/libxc/4.3.4_build1/GNU, since this script should
# be run in something like
# /work/y07/y07/cse/libxc/4.3.4_build1/GNU/build.
prefix=$(readlink -f $PWD/..)
(
    cd libxc-4.3.4
    make install &> install.log
)
