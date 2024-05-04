#!/usr/bin/bash

# Note that the OpenFOAM ./etc/bashrc requires that this be run
# interactively (for reasons that I don't understand yet), and
# not in the queue system.

#set -e

source ./site/modules.sh
source ./site/version.sh
module list

cd OpenFOAM-${version}

source ./etc/bashrc

./Allwmake -j 12
