Building CPL-OpenFOAM-LAMMPS on ARCHER2 (GCC 10.2.0)
====================================================

These instructions are for building CPL-OpenFOAM LAMMPS on ARCHER2 using the GNU compilers.  

At present, as a stepping stone to the full installation of the coupling a OpenFOAM simulation with a LAMMPS simulatino using the CPL coupler library, we first install a related OpenFOAM simulation with a dummy LAMMPS simulation, namely CPL_APP_OPENFOAM

Download CPL
---------------

Clone the latest version of CPL from the GitHub repository:

   `git clone https://github.com/Crompulence/cpl-library.git`

Setup your environment
----------------------

Load the correct modules:

   ```bash
   module restore
   module load openfoam/com/v2106
   module load lammps/13_Jun_2022
   module load cray-python
   ```

Compile and enable CPL library with make
----------------------------------------
Move into the build directory:

  `cd cpl-library`

Run make:

  ```
  make PLATFORM=ARCHER2
  ```

This will create the CPL library.

Install CPL library:

  `source SOURCEME.sh`

Download CPL_APP_OPENFOAM
-------------------------

Clone the latest version of CPL_APP_OPENFOAM from the GitHub repository:

   `git clone https://github.com/Crompulence/cpl-library.git`

Setup your environment further
------------------------------

Configure environment 

   ```bash
   cd CPL_APP_OPENFOAM
   echo $FOAM_INSTALL_DIR > CODE_INST_DIR
   # the following SOURCEME.sh is different from the SOURCEME.sh above
   source SOURCEME.sh
   export FOAM_USER_APPBIN=$FOAM_CPL_APP_BIN
   export FOAM_USER_LIBBIN=$FOAM_CPL_APP_LIBBIN
   cd src;ln -s CPLPstream_v2106 CPLPstream;cd ..
   ```

Compile CPL_APP_OPENFOAM application with make
----------------------------------------------
Run make:

  ```
  make PLATFORM=ARCHER2
  ```
