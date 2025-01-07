#!/bin/bash --login

#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=00:10:00

#SBATCH --partition=standard
#SBATCH --qos=standard
#SBATCH --account=z19

#SBATCH --export=none

printf "Start: %s\n" "`date`"

# To replace the module command, e.g.,
#module load openfoam/org/v9.20210903

# .. use the following three lines

source ./site/modules.sh
source ./site/version.sh
export FOAM_INSTALL_DIR=$(pwd)/OpenFOAM-${version_major}

# Run test

source ${FOAM_INSTALL_DIR}/etc/bashrc || printf ".etc/bashrc returns $?\n"

rm -rf test
source ./site/test.sh

printf "Finish: %s\n" "`date`"
