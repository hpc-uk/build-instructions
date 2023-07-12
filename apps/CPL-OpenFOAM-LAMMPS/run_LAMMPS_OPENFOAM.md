Run Instructions for LAMMPS-OPENFOAM
====================================================

These instructions are to run the LAMMPS-OPENFOAM example on Archer2

Setup your environment
----------------------
Load the correct modules, which loads modules OpenFOAM/v2106, the most recent version of LAMMPS and cray-python, then enables cpl-library by setting $CPL_PATH along with the $CPL_PATH/SOURCEME.sh commands, and sets $FOAM_CPL_APP.  The source line below runs $FOAM_CPL_APP/SOURCEME.sh, which includes source of the OpenFOAM bashrc file.

   ```bash
   module load other-software
   module load cpl-openfoam
   source $FOAM_CPL_APP/SOURCEME.sh
   module load cpl-lammps
   ```

Copy and build MD exectuable
----------------------------
Recursively copy the CPLTestSocketForm example directory into your work directory and build the MD exectuable, e.g.:

   ```bash
   cd /work/t42/t42/gavin
   cp -r $CPL_PATH/example/LAMMPS_OPENFOAM .
   cd LAMMPS_OPENFOAM
   ```

Create and submit batch script
------------------------------
Create the batch script similar to the following

   ```bash
   #!/bin/bash

   #SBATCH --job-name=my_cpl_demo
   #SBATCH --time=0:30:0
   #SBATCH --exclusive
   #SBATCH --export=none
   #SBATCH --account=y23
   #SBATCH --partition=standard
   #SBATCH --qos=standard
   #SBATCH --nodes=2

   # single thread export overriders any declaration in srun
   export OMP_NUM_THREADS=1

   module load other-software
   module load cpl-openfoam
   source $FOAM_CPL_APP/SOURCEME.sh
   module load cpl-lammps

   cd openfoam
   python clean.py -f
   blockMesh
   decomposePar
   cd ..

   SHARED_ARGS="--distribution=block:block --hint=nomultithread"

   srun ${SHARED_ARGS} --het-group=0 --nodes=1 --tasks-per-node=2  CPLIcoFoam -case ./openfoam -parallel : --het-group=1 --nodes=1 --tasks-per-node=2 lmp_cpl -i lammps.in

   ```

