#!/bin/bash --login

#SBATCH --partition=standard
#SBATCH --qos=standard

#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --tasks-per-node=1
#SBATCH --time=02:00:00

printf "Start: %s\n" "`date`"

source ./site/compile.sh

# Record the envoronment variables

set | grep FOAM\_
set | grep WM\_

printf "Finish: %s\n" "`date`"
