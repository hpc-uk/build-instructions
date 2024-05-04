#!/bin/bash --login

#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --tasks-per-node=1
#SBATCH --time=06:00:00

#SBATCH --partition=standard
#SBATCH --qos=standard

printf "Start: %s\n" "`date`"

source ./site/modules.sh
module list

source ./site/compile.sh

# Record the envoronment variables

set | grep FOAM\_
set | grep WM\_

printf "Finish: %s\n" "`date`"
