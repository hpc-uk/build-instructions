#!/usr/bin/bash

set -e

# OpenFOAM Patch Release 1st Sept 2020
# See https://openfoam.org/news/v8-patch/

wget -O OpenFOAM-8-20200901.tar.gz http://dl.openfoam.org/source/8.20200901
wget -O ThirdParty-8-version-8.tar.gz http://dl.openfoam.org/third-party/8

# Note openfoam.org recommend renaming the source directory without
# the extension, although we need to remember somewhere exactly
# what version it is...
# ...

tar xf OpenFOAM-8-20200901.tar.gz
tar xf ThirdParty-8-version-8.tar.gz

mv OpenFOAM-8-20200901 OpenFOAM-8
mv ThirdParty-8-version-8 ThirdParty-8

