#!/bin/bash --login

#SBATCH --nodes=1
#SBATCH --partition=standard
#SBATCH --qos=standard

#SBATCH --exclusive
#SBATCH --tasks-per-node=1
#SBATCH --time=03:00:00

printf "Start: %s\n" "`date`"

export FOAM_VERBOSE=1

source ./site/modules.sh
module list

# cray-fftw provides FFTW_DIR is appropriate as lib location ...
export FFTW_ARCH_PATH=${FFTW_DIR}

source ./site/compile.sh

# Record the envoronment variables

set | grep FOAM\_
set | grep WM\_

printf "Finish: %s\n" "`date`"
