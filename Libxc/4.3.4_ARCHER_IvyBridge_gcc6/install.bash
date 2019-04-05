#!/bin/bash
module switch PrgEnv-$(echo $PE_ENV | tr '[:upper:]' '[:lower:]') PrgEnv-gnu 

export CC=cc
export FC=ftn
export CRAYPE_LINK_TYPE=dynamic
(
    cd libxc-4.3.4
    make install &> install.log
)
