#!/bin/bash
#
#PBS -l select=serial=true:ncpus=1
#PBS -l walltime=12:00:00
#PBS -A z19-cse

cd $PBS_O_WORKDIR

source ./site/modules.sh

# Additional local environment

export CRAYPE_LINK_TYPE=dynamic
export CRAY_ADD_RPATH=yes

cd OpenFOAM-7

source ./etc/bashrc

./Allwmake

# Record environment variables
set | grep FOAM
set | grep WM
