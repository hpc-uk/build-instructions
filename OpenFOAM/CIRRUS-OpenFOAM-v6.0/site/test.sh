#!/usr/bin/bash

# This script itself is not particularly robust to failure.

# Serial test
mkdir test
cd test
cp -r ${FOAM_TUTORIALS}/multiphase/interFoam/laminar/damBreak/damBreak .
cd damBreak
blockMesh
cp 0/alpha.water.orig 0/alpha.water
setFields
interFoam

# Parallel test

cd ..
foamCloneCase damBreak damBreakPar
cd damBreakPar
cp 0/alpha.water.orig 0/alpha.water
setFields
decomposePar
srun -n 4 interFoam -parallel
