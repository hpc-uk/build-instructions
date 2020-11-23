#!/bin/bash

# To install OpenFOAM 7.0
# See https://openfoam.org/download/7-source/

# Download the source, and the third party stuff (scotch)

wget -O OpenFOAM-7-version-7.tar.gz http://dl.openfoam.org/source/7
wget -O ThirdParty-7-version-7.tar.gz http://dl.openfoam.org/third-party/7

# Unpack the components to the required final directory names:

mkdir OpenFOAM-7
mkdir ThirdParty-7

tar zxf OpenFOAM-7-version-7.tar.gz --strip-components=1 -C OpenFOAM-7
tar zxf ThirdParty-7-version-7.tar.gz --strip-components=1 -C ThirdParty-7
