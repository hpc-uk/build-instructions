#!/bin/bash

set -e

# Invoke from the parent directory...

export FOAM_INST_DIR=${PWD%/site}
export FOAM_SRC=${FOAM_INST_DIR}/OpenFOAM-7
export FOAM_THIRDPARTY=${FOAM_INST_DIR}/ThirdParty-7
printf "Install OpenFOAM-7 in FOAM_INST_DIR: %s\n" ${FOAM_INST_DIR}

# Install our site-specific extras from ./site
# OpenFoam does't deal very well (or at all) with Cray MPICH
# from the environment, so we have edited the settings script
# and replace it here. Further relevant environment variables
# come from ./etc/prefs.sh (included in ${FOAM_SRC}/etc/bashrc).

settings=etc/config.sh/settings
cp ${FOAM_INST_DIR}/site/$settings ${FOAM_SRC}/$settings

# Add appropriate rules for crayGcc

rules=wmake/rules/crayGcc
cp -r ${FOAM_INST_DIR}/site/$rules ${FOAM_SRC}/$rules

# Third Party scotch Makefile
# Replace "gcc" and "mpicc" by "$(WM_CC)"

file="${FOAM_THIRDPARTY}/etc/wmakeFiles/scotch/Makefile.inc.i686_pc_linux2.shlib-OpenFOAM"

sed -i "s/gcc/\$(WM_CC)/"    ${file}
sed -i "s/mpicc/\$(WM_CC)/"  ${file}
