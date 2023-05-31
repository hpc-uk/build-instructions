#!/usr/bin/bash

set -e

source ./site/version.sh

# To be run from FOAM_INST_DIR
# I make the dependencies first.

cd OpenFOAM-${version_major}

source ../site/modules.sh
source ./etc/bashrc || printf "./etc/bashrc returned %s\n" "$?"

./Allwmake -j 16 dep
./Allwmake -j 16

