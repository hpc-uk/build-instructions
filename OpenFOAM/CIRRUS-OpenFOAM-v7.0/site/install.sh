#!/usr/bin/bash

# See https://openfoam.org/news/v7-patch/
# The third party stuff is the standard v7 release (there's no corresponding
# patch).

wget -O OpenFOAM-7-20190902.tar.gz http://dl.openfoam.org/source/7.20190902
wget -O ThirdParty-7-version-7.tar.gz http://dl.openfoam.org/third-party/7

# Note openfoam.org recommend renaming the source directory without
# the extension, although we need to remember somewhere exactly
# what version it is...
# ...

tar zxf OpenFOAM-7-20190902.tar.gz
tar zxf ThirdParty-7-version-7.tar.gz

mv OpenFOAM-7-20190902 OpenFOAM-7
mv ThirdParty-7-version-7 ThirdParty-7

