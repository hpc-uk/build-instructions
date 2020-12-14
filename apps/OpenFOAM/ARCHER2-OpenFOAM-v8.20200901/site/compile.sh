#!/usr/bin/env bash

set -e

# To be run from FOAM_INST_DIR
# I make the dependencies first.

cd OpenFOAM-8

source ../site/modules.sh
source ./etc/bashrc || printf "./etc/bashrc returned %s\n" "$?"

./Allwmake -j 16 dep
./Allwmake -j 64 
