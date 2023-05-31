#!/usr/bin/bash

set -e

export FOAM_INST_DIR=$(pwd)
source ./site/version.sh

wget -O OpenFOAM-${version_major}-${version_patch}.tar.gz \
     http://dl.openfoam.org/source/${version}
wget -O ThirdParty-${version_major}-version-${version_major}.tar.gz \
     http://dl.openfoam.org/third-party/${version_major}

# Note openfoam.org recommend renaming the source directory without
# the extension, although we need to remember somewhere exactly
# what version it is...
# ...

tar xf OpenFOAM-${version_major}-${version_patch}.tar.gz
tar xf ThirdParty-${version_major}-version-${version_major}.tar.gz

mv OpenFOAM-${version_major}-${version_patch} OpenFOAM-${version_major}
mv ThirdParty-${version_major}-version-${version_major} ThirdParty-${version_major}


