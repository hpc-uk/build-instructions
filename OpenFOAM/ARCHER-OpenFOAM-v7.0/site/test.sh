#!/bin/bash --login
#
#PBS -l select=4
#PBS -l walltime=00:20:00
#PBS -A z19-cse

cd $PBS_O_WORKDIR

cd OpenFOAM-7

source ./etc/bashrc

cd ..

# Full test of icoFoam cavity

mkdir -p icoFoam

cp -pr ${FOAM_TUTORIALS}/incompressible/icoFoam/cavity/cavity icoFoam
cd icoFoam/cavity

aprun -n 1 blockMesh > test-blockMesh.log 2>&1

cp $PBS_O_WORKDIR/decomposeParDict system

aprun -n 1 decomposePar > test-decomposePar.log 2>&1
aprun -n 16 -N 4 -S 2 icoFoam -parallel > test-icoFoam.log 2>&1

# Just copy the output to stdout for convenience

cat test-blockMesh.log
cat test-decomposePar.log
cat test-icoFoam.log

