#!/usr/bin/bash

# This script itself is not particularly robust to failure.
# See https://doc.cfd.direct/openfoam/user-guide-v12/dambreak

# Serial test
mkdir test
cd test
cp -r ${FOAM_TUTORIALS}/incompressibleVoF/damBreakLaminar .
cd damBreakLaminar
blockMesh
cp 0/alpha.water.orig 0/alpha.water
setFields
foamRun

# Parallel test
# The default decomposePar script wants 8 processes

cd ..
foamCloneCase damBreakLaminar damBreakLaminarPar
cd damBreakLaminarPar
cp 0/alpha.water.orig 0/alpha.water
setFields
foamGet decomposeParDict
decomposePar
srun -n 8 foamRun -parallel

