#!/bin/bash

#SBATCH --partition=standard
#SBATCH --qos=short

#SBATCH --time=00:20:00
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --export=none

#SBATCH --hint=nomultithread
#SBATCH --distribution=block:block

module load PrgEnv-gnu

# FHI_AIMS_ROOT needs to be set appropriately.

export FHI_AIMS_ROOT=$(pwd)/fhi-aims/fhi-aims.210716_2
export OMP_NUM_THREADS=1

cp ${FHI_AIMS_ROOT}/benchmarks/Ac-Lys-Ala19-H/control.in .
cp ${FHI_AIMS_ROOT}/benchmarks/Ac-Lys-Ala19-H/geometry.in .

sed -i '/collect\_eigenvectors/d' control.in

srun --ntasks=48 --unbuffered  ${FHI_AIMS_ROOT}/_build-gnu/aims.210716_2.scalapack.mpi.x

