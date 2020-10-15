#!/usr/bin/bash

# To be run from FOAM_INST_DIR
# I make the dependencies first.

cd OpenFOAM-6
source ./etc/bashrc

./Allwmake -j  8 dep
./Allwmake -j 36 
