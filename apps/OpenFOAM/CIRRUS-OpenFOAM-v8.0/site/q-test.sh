#!/bin/bash --login

#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=00:10:00
#SBATCH --account=z04

#SBATCH --partition=standard
#SBATCH --qos=standard

printf "Start: %s\n" "`date`"

# Replaces, e.g.,
# module load openfoam/v8.0

source ./site/modules.sh

export FOAM_INSTALL_PATH=`pwd`/OpenFOAM-8

# Run test

source ${FOAM_INSTALL_PATH}/etc/bashrc

source ./site/test.sh

printf "Finish: %s\n" "`date`"
