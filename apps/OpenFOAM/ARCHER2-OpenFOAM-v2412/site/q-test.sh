#!/bin/bash 

#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=00:10:00

#SBATCH --partition=standard
#SBATCH --qos=short
#SBATCH --export=none

set | grep SLURM

printf "Start: %s\n" "$(date)"

# Replaces, e.g.,

#module load openfoam/com

source ./site/version.sh
source ./site/modules.sh

export FOAM_INSTALL_DIR=$(pwd)/OpenFOAM-${version}
printf "FOAM_INSTALL_DIR is %s\n" "${FOAM_INSTALL_DIR}"

# Run test

source ${FOAM_INSTALL_DIR}/etc/bashrc || printf ".etc/baschrc returns $?\n"

printf "Run test script\n"
source ./site/test.sh

printf "Finish: %s\n" "$(date)"
