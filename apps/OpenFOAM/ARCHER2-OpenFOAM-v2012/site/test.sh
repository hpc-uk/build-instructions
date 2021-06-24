#!/usr/bin/bash

# This script itself is not particularly robust to failure.

# Serial test
mkdir test
cd test
cp -r ${FOAM_TUTORIALS}/multiphase/interFoam/laminar/damBreak/damBreak .
cd damBreak
blockMesh
cp -r 0.orig 0
setFields
interFoam

# Parallel test

cd ..
foamCloneCase damBreak damBreakPar
cd damBreakPar
setFields
decomposePar
srun -n 4 interFoam -parallel
