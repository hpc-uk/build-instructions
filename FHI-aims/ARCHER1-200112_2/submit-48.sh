#!/bin/bash

#PBS -l select=2
#PBS -l walltime=00:20:00
#PBS -j oe
#PBS -A z19-cse

# Directory from which PBS' qsub command was called.
cd $PBS_O_WORKDIR

# FHI-aims version variable to call the right binary (see below).

export FHI_AIMS_ROOT=/work/z01/z01/kevin/fhi-aims.200112_2
aims_version="200112_2.scalapack.mpi"

export OMP_NUM_THREADS=1

cp ${FHI_AIMS_ROOT}/benchmarks/Ac-Lys-Ala19-H/control.in .
cp ${FHI_AIMS_ROOT}/benchmarks/Ac-Lys-Ala19-H/geometry.in .

aprun -n 48 -N 24 ${FHI_AIMS_ROOT}/build-intel/aims.$aims_version.x < /dev/null
