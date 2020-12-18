#!/usr/bin/env bash

set -e

# OpenFoam v2006 (June 2020)
# https://www.openfoam.com/download/install-source.php

export FOAM_INST_DIR=`pwd`
export version="v2006"

# This takes a few minutes.

wget https://sourceforge.net/projects/openfoam/files/v2006/OpenFOAM-v2006.tgz
wget https://sourceforge.net/projects/openfoam/files/v2006/ThirdParty-v2006.tgz

tar zxf OpenFOAM-${version}.tgz
tar zxf ThirdParty-${version}.tgz

# Patch various issues

export FOAM_SRC=${FOAM_INST_DIR}/OpenFOAM-${version}
export FOAM_THIRDPARTY=${FOAM_INST_DIR}/ThirdParty-${version}
printf "Install OpenFOAM in FOAM_INST_DIR: %s\n" ${FOAM_INST_DIR}

# Install our site-specific preferences from ./site

cp ./site/prefs.sh ${FOAM_SRC}/etc/prefs.sh

