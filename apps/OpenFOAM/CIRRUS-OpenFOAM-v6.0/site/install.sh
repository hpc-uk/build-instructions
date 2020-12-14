#!/usr/bin/bash

# See https://openfoam.org/download/6-source/

wget -O OpenFOAM-6-version-6.tar.gz http://dl.openfoam.org/source/6
wget -O ThirdParty-6-version-6.tar.gz http://dl.openfoam.org/third-party/6

# Reorganise the directory names (the downloads are a bit weird)...

tar zxf OpenFOAM-6-version-6.tar.gz
tar zxf ThirdParty-6-version-6.tar.gz

mv OpenFOAM-6-version-6 OpenFOAM-6
mv ThirdParty-6-version-6 ThirdParty-6

