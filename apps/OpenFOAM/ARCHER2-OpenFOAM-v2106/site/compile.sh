#!/usr/bin/env bash

# To be run from FOAM_INST_DIR
# I make the dependencies first.

source ./site/modules.sh

cd OpenFOAM-v2106
source ./etc/bashrc


./Allwmake -j 16 dep
./Allwmake -j 16 
