#!/bin/bash --login

#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=00:10:00

#SBATCH --partition=standard
#SBATCH --qos=standard
#SBATCH --export=none

set | grep SLURM

printf "Start: %s\n" "`date`"

# Replaces, e.g.,
# module load openfoam/com/version

source ./site/modules.sh

export FOAM_INSTALL_PATH=`pwd`/OpenFOAM-v2106

# Run test

source ${FOAM_INSTALL_PATH}/etc/bashrc

source ./site/test.sh

printf "Finish: %s\n" "`date`"
