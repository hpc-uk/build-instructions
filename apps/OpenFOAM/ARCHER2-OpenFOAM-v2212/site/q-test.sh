#!/bin/bash --login

#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=00:10:00

#SBATCH --partition=standard
#SBATCH --qos=standard
#SBATCH --export=none

#SBATCH --account=z19

set | grep SLURM

printf "Start: %s\n" "`date`"

# Replaces, e.g.,

module load openfoam/com/v2106

# Run test

source ${FOAM_INSTALL_DIR}/etc/bashrc

source ./site/test.sh

printf "Finish: %s\n" "`date`"
