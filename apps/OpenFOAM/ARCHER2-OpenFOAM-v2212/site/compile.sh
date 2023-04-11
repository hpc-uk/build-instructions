#!/usr/bin/env bash

# To be run from FOAM_INST_DIR
# I make the dependencies first.

source ./site/version.sh
source ./site/modules.sh

cd OpenFOAM-${version}
source ./etc/bashrc


./Allwmake -j 16 dep
./Allwmake -j 16 
