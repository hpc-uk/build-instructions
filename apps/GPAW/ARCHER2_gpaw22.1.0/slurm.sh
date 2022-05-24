#!/bin/bash

#SBATCH --time=00:02:00
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --partition=standard
#SBATCH --qos=short
#SBATCH --export=none

module load PrgEnv-gnu
module load cray-python
module load cray-fftw

# We assume this script is in the top level directory where GPAW has
# been installed.

export MY_PREFIX=$(pwd)
export LIBXC_DIR=${MY_PREFIX}
export GPAW_DIR=${MY_PREFIX}
export GPAW_SETUP_PATH=${GPAW_DIR}/gpaw-setups-0.9.20000

export PATH=${GPAW_DIR}/bin:${PATH}
export LB_LIBRARY_PATH=${GPAW_DIR}/lib:${LIBXC_DIR}/lib:${LD_LIBRARY_PATH}
export PYTHONPATH=${GPAW_DIR}/lib/python3.8/site-packages:${PYTHONPATH}

# While we have not built GPAW with OpenMP, we still set OMP_NUM_THREADS
# in case it is used in any dependent libraries.

export OMP_NUM_THREADS=1

srun --ntasks=8 gpaw test
