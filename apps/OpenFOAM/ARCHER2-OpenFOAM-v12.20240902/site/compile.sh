#!/usr/bin/env bash

set -e

source ./site/version.sh

# To be run from FOAM_INST_DIR
# I make the dependencies first.

cd OpenFOAM-${version_major}

export FOAM_INST_DIR=$(pwd)

source ../site/modules.sh
source ./etc/bashrc || printf "./etc/bashrc returned %s\n" "$?"

# It can be useful to run make twice; the second time should give
# a clearer picture of the outcome.

./Allwmake -j 16
./Allwmake -j 1
