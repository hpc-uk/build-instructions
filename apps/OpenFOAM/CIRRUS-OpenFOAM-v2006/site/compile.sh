#!/usr/bin/bash

# Note that the OpenFOAM ./etc/bashrc requires that this be run
# interactively (for reasons that I don't understand yet), and
# not in the queue system.

set -e

cd OpenFOAM-v2006

source ../site/modules.sh
module list

source ./etc/bashrc

./Allwmake -j 12
