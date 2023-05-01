#!/usr/bin/env bash

set -e

# OpenFoam v2106 (June 2021)
# https://www.openfoam.com/download/openfoam-installation-from-source

export FOAM_INST_DIR=`pwd`
export version="v2106"

# This takes a few minutes.

wget https://sourceforge.net/projects/openfoam/files/${version}/OpenFOAM-${version}.tgz
wget https://sourceforge.net/projects/openfoam/files/${version}/ThirdParty-${version}.tgz

tar zxf OpenFOAM-${version}.tgz
tar zxf ThirdParty-${version}.tgz

# Patch various issues

export FOAM_SRC=${FOAM_INST_DIR}/OpenFOAM-${version}
export FOAM_THIRDPARTY=${FOAM_INST_DIR}/ThirdParty-${version}
printf "Install OpenFOAM in FOAM_INST_DIR: %s\n" ${FOAM_INST_DIR}

# Install our site-specific preferences from ./site

cp ./site/prefs.sh ${FOAM_SRC}/etc/prefs.sh

# Thridparty patches

# Scotch
# Remove the "-m64" from the link stage in the Makefile
# that is, remove "$(WM_LDFLAGS)"

file=${FOAM_THIRDPARTY}/etc/makeFiles/scotch/Makefile.inc.OpenFOAM-Linux.shlib

sed -i "s/\$(WM_LDFLAGS)//" ${file}

# We will use FFTW from cray-fftw:
# fftw_version=fftw-system
# Remove FFTW_ARCH_PATH

config_file=${FOAM_SRC}/etc/config.sh/FFTW

sed -i "s/^fftw_version.*/fftw_version=fftw-system/" ${config_file}
sed -i "s/^export FFTW_ARCH_PATH.*//" ${config_file}

# Disable the paraview build cleanly:
# ParaView_VERSION=none

config_file=${FOAM_SRC}/etc/config.sh/paraview

sed -i "s/^ParaView_VERSION.*/ParaView_VERSION=none/" ${config_file}
