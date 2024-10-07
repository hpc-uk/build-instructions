#!/bin/bash --login

#SBATCH --exclusive
#SBATCH --nodes=2
#SBATCH --tasks-per-node=36
#SBATCH --cpus-per-task=1

#SBATCH --time=00:20:00

#SBATCH --account=YOUR_ACCOUNT_CODE_HERE
#SBATCH --partition=standard
#SBATCH --qos=standard

module load intel-20.4/compilers
module load intel-20.4/mpi
module load intel-20.4/fc
module load intel-20.4/cmkl

# Assume we have installed FHI Aims in home directory...

PREFIX=/path/to/installation
export FHI_AIMS_ROOT=${PREFIX}/fhi-aims.240920 
aims_version="240920.scalapack.mpi"

export OMP_NUM_THREADS=1

cp ${FHI_AIMS_ROOT}/benchmarks/Ac-Lys-Ala19-H/control.in .
cp ${FHI_AIMS_ROOT}/benchmarks/Ac-Lys-Ala19-H/geometry.in .

srun ${FHI_AIMS_ROOT}/build-intel/aims.$aims_version.x < /dev/null
