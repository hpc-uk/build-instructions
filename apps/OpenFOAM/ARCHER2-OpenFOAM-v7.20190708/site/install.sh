#!/usr/bin/bash

set -e

# OpenFOAM 7 2019
# See https://openfoam.org/download/7-source/

wget -O OpenFOAM-7-version-7.tar.gz http://dl.openfoam.org/source/7
wget -O ThirdParty-7-version-7.tar.gz http://dl.openfoam.org/third-party/7

# Note openfoam.org recommend renaming the source directory without
# the extension, although we need to remember somewhere exactly
# what version it is...
# ...

tar xf OpenFOAM-7-version-7.tar.gz
tar xf ThirdParty-7-version-7.tar.gz

mv OpenFOAM-7-version-7 OpenFOAM-7
mv ThirdParty-7-version-7 ThirdParty-7

