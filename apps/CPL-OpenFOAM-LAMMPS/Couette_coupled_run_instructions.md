Run Instructions for Couette_coupled/Partial_overlap
====================================================

These instructions are to run the Couette_coupled/Partial_overlap example on Archer2

Setup your environment
----------------------
Load the correct modules, which loads modules OpenFOAM/v2106, the most recent version of LAMMPS and cray-python, then enables cpl-library by setting $CPL_PATH along with the $CPL_PATH/SOURCEME.sh commands, and sets $FOAM_CPL_APP.  The source line below runs $FOAM_CPL_APP/SOURCEME.sh, which includes source of the OpenFOAM bashrc file.

   ```bash
   module load other-software
   module load cpl-lammps
   ```

Copy and build MD exectuable
----------------------------
Recursively copy the CPLTestSocketForm example directory into your work directory and build the MD exectuable, e.g.:

   ```bash
   cd /work/t42/t42/gavin
   cp -r $LAMMPS_CPL_APP/test/Couette_coupled .
   cd Couette_coupled/Partial_overlap
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
   #SBATCH --account=ecseaf01
   #SBATCH --partition=standard
   #SBATCH --qos=standard
# at least two nodes are required, as each application coupled requires at least one node each
   #SBATCH --nodes=2
# single thread export overriders any declaration in srun
   export OMP_NUM_THREADS=1
   module load other-software
   module load cpl-lammps
   srun ${SHARED_ARGS} --het-group=0 --nodes=1 --tasks-per-node=1 lmp_cpl -in ./one_wall_imaginary_sliding_coupled.in :  --het-group=1 --nodes=1 --tasks-per-node=1 python ./python_dummy/CFD_test_vs_Couette.py
   ```
