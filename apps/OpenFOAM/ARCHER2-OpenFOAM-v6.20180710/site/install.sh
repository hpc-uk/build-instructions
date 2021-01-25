#!/usr/bin/bash

set -e

# OpenFOAM 6 2018
# See https://openfoam.org/download/6-linux/

wget -O OpenFOAM-6-version-6.tar.gz http://dl.openfoam.org/source/6
wget -O ThirdParty-6-version-6.tar.gz http://dl.openfoam.org/third-party/6

# Note openfoam.org recommend renaming the source directory without
# the extension, although we need to remember somewhere exactly
# what version it is...
# ...

tar xf OpenFOAM-6-version-6.tar.gz
tar xf ThirdParty-6-version-6.tar.gz

mv OpenFOAM-6-version-6 OpenFOAM-6
mv ThirdParty-6-version-6 ThirdParty-6

