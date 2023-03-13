Run Instructions for CPLTestSocketFoam
======================================

These instructions are to run the CPLTestSocketFoam example on Archer2

Setup your environment
----------------------
Load the correct modules, which loads modules OpenFOAM/v2106, LAMMPS/13_Jun_2022 and cray-python, then enables cpl-library by setting $CPL_PATH along with the $CPL_PATH/SOURCEME.sh commands, and sets $FOAM_CPL_APP.  The source line below runs $FOAM_CPL_APP/SOURCEME.sh, which includes source of the OpenFOAM bashrc file.

   ```bash
   module load other-software
   module load cpl-openfoam/2106
   source $FOAM_CPL_APP/SOURCEME.sh
   ```

Copy and build MD exectuable
----------------------------
Recursively copy the CPLTestSocketForm example directory into your work directory and build the MD exectuable, e.g.:

   ```bash
   cd /work/t42/t42/gavin
   cp -r $FOAM_CPL_APP/examples/CPLTestSocketFoam .
   cd CPLTestSocketFoam
   cplc++ minimal_MD.cpp -o MD
   ```

Create and submit batch script
------------------------------
Create the batch script similar to the following

   ```bash
   #!/bin/bash

   #SBATCH --job-name=my_cpl_test
   #SBATCH --time=0:10:0
   #SBATCH --exclusive
   #SBATCH --export=none
   
   # you will need to change the account code
   #SBATCH --account=t42
   #SBATCH --partition=standard
   #SBATCH --qos=standard
   
   # at least two nodes are required, as each application coupled requires at least one node each
   #SBATCH --nodes=2
   
   # single thread export overriders any declaration in srun
   export OMP_NUM_THREADS=1
   
   # once again load the modules
   module load other-software
   module load cpl-openfoam/2106
   source $FOAM_CPL_APP/SOURCEME.sh

   # using your own installtion: remove the last three lines and use these four lines instead
   # remmeber to update the path to the two SOURCEME.sh files
   #module load openfoam/com/v2106
   #module load lammps/13_Jun_2022
   #module load cray-python
   #source /work/y23/shared/cpl-openfoam-lammps/cpl-library/SOURCEME.sh
   #source /work/y23/shared/cpl-openfoam-lammps/CPL_APP_OPENFOAM/SOURCEME.sh
   
   # run blockMesh and decompasePar
   # NB these are both serial codes and should only be run within a parallel job if
   # they are short and the parallel jobs does not employ a high core count
   blockMesh
   decomposePar -force
   
   # set SHARED_ARGS environment variable
   SHARED_ARGS="--distribution=block:block --hint=nomultithread"
   
   # srun the MD executable and the CPLTestScoketFoam executable in a shared
   # MD is copied from the y23 project, but can be built locally 
   # CPLTestSocketFoam is not copied but its location resides in the users PATH 
   srun ${SHARED_ARGS} --het-group=0 --nodes=1 --tasks-per-node=2 MD : --het-group=1 --nodes=1 --tasks-per-node=2 CPLTestSocketFoam -parallel
   ```
