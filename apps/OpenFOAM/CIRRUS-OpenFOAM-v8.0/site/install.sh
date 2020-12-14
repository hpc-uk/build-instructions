#!/usr/bin/bash

set -e

# See https://openfoam.org/download/8-source

wget -O OpenFOAM-8-20200722.tar.gz http://dl.openfoam.org/source/8
wget -O ThirdParty-8-version-8.tar.gz http://dl.openfoam.org/third-party/8

# Note openfoam.org recommend renaming the source directory without
# the extension, although we need to remember somewhere exactly
# what version it is...
# ...

tar xf OpenFOAM-8-20200722.tar.gz
tar xf ThirdParty-8-version-8.tar.gz

mv OpenFOAM-8-version-8 OpenFOAM-8
mv ThirdParty-8-version-8 ThirdParty-8

