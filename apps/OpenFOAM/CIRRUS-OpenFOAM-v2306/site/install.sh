#!/usr/bin/env bash

set -e

# Download the source and unpack

export FOAM_INST_DIR=$(pwd)
source ./site/version.sh

# This takes a few minutes.

wget https://sourceforge.net/projects/openfoam/files/${version}/OpenFOAM-${version}.tgz
wget https://sourceforge.net/projects/openfoam/files/${version}/ThirdParty-${version}.tgz

tar xf OpenFOAM-${version}.tgz
tar xf ThirdParty-${version}.tgz

# Patch various issues

export FOAM_SRC=${FOAM_INST_DIR}/OpenFOAM-${version}
export FOAM_THIRDPARTY=${FOAM_INST_DIR}/ThirdParty-${version}
printf "Install OpenFOAM in FOAM_INST_DIR: %s\n" ${FOAM_INST_DIR}

# Install our site-specific preferences from ./site

cp ./site/prefs.sh ${FOAM_SRC}/etc/prefs.sh

