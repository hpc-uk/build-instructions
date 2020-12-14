#!/bin/bash

# Dependencies must be run interactively (will fail in serial queue)
# (also builds ThirdParty stuff)
# Takes 8-10 minutes.

cd OpenFOAM-7

source ./etc/bashrc
./Allwmake -j 8 dep

cd ..