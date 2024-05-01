#!/bin/bash

#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=00:10:00

#SBATCH --partition=standard
#SBATCH --qos=standard

printf "Start: %s\n" "$(date)"

# Replaces, e.g.,

source ./site/version.sh
module load openfoam/${version}
module  list

printf  "FOAM_INSTALL_PATH %s\n"" ${FOAM_INSTALL_PATH}"

# Run test

source ${FOAM_INSTALL_PATH}/etc/bashrc

source ./site/test.sh

printf "Finish: %s\n" "$(date)"
