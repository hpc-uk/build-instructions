#!/bin/bash --login

#SBATCH --exclusive
#SBATCH --nodes=2
#SBATCH --tasks-per-node=36
#SBATCH --cpus-per-task=1

#SBATCH --time=00:20:00

#SBATCH --partition=standard
#SBATCH --qos=standard

module load mpt
module load intel-tools-19

export FHI_AIMS_ROOT=${HOME}/fhi-aims.200112_2
aims_version="200112_2.scalapack.mpi"

export OMP_NUM_THREADS=1

cp ${FHI_AIMS_ROOT}/benchmarks/Ac-Lys-Ala19-H/control.in .
cp ${FHI_AIMS_ROOT}/benchmarks/Ac-Lys-Ala19-H/geometry.in .

srun ${FHI_AIMS_ROOT}/build-gnu/aims.$aims_version.x < /dev/null

