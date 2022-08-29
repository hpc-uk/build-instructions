#!/bin/bash

#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=00:10:00
#SBATCH --account=z04

#SBATCH --partition=standard
#SBATCH --qos=standard

printf "Start: %s\n" "$(date)"

# Replaces, e.g.,
# module load openfoam/${version}

source ./site/modules.sh
source ./site/version.sh

export FOAM_INSTALL_PATH=$(pwd)/OpenFOAM-${version}

module  list
printf  "FOAM_INSTALL_PATH %s\n"" ${FOAM_INSTALL_PATH}"

# Run test

source ${FOAM_INSTALL_PATH}/etc/bashrc

source ./site/test.sh

printf "Finish: %s\n" "$(date)"
