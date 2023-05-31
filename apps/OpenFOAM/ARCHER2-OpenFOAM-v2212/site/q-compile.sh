#!/bin/bash --login

#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --tasks-per-node=1
#SBATCH --time=03:00:00

printf "Start: %s\n" "`date`"

export FOAM_VERBOSE=1

source ./site/modules.sh
module list

source ./site/compile.sh

# Record the envoronment variables

set | grep FOAM\_
set | grep WM\_

printf "Finish: %s\n" "`date`"
