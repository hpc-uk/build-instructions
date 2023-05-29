Building CPL-OpenFOAM-LAMMPS on ARCHER2 (GCC 10.2.0)
====================================================

These instructions are for building CPL-OpenFOAM LAMMPS on ARCHER2 using the GNU compilers.

At present, as a stepping stone to the full installation of the coupling a OpenFOAM simulation with a LAMMPS simulatino using the CPL coupler library, we first install the CPL library.  Secondly, we install a related OpenFOAM simulation with a dummy LAMMPS simulation, namely CPL_APP_OPENFOAM.  This is follows by the installatoin of a LAMMPS simulation with a dummy OpenFOAM simulation, namely CPL_APP_LAMMPS-DEV.

Download CPL
---------------

Clone the latest version of CPL from the GitHub repository:

   `git clone git@github.com:Crompulence/cpl-library.git`

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

Add group write permissions on examples
------------------------------------------

Change permissions such that group members also have write permissions on files in examples, then return to parent directory

  ```
  find examples -type d -exec chmod 775 {} \;
  find examples -type f -exec chmod 664 {} \;
  find examples -name *.py -exec chmod 775 {} \;
  cd ..
  ```

Download CPL_APP_OPENFOAM
-------------------------

Clone the latest version of CPL_APP_OPENFOAM from the GitHub repository:

   `git clone git@github.com:Crompulence/CPL_APP_OPENFOAM.git`

Setup your environment further
------------------------------

Configure environment

   ```bash
   cd CPL_APP_OPENFOAM
   # the following SOURCEME.sh is different from the SOURCEME.sh above
   source SOURCEME.sh
   cd src;ln -s CPLPstream_v2106 CPLPstream;cd ..
   ```

Add group write permissions on examples
------------------------------------------

As for cpl-library above, change permissions such that group members also have write permissions on files in examples, then return to parent directory

  ```
  find examples -type d -exec chmod 775 {} \;
  find examples -type f -exec chmod 664 {} \;
  find examples -name *.py -exec chmod 775 {} \;
  ```

Compile CPL_APP_OPENFOAM applications with make
-----------------------------------------------
Run make:

  ```
  make pstream
  make cpltestfoam
  make cpltestsocketfoam
  make cplinterfoam
  ```
  
Download Download CPL_APP_LAMMPS-DEV
------------------------------------

Clone the latest version of CPL_APP_LAMMPS-DEV from the GitHub repository. This includes the latest LAMMPS version.

   `git clone git@github.com:Crompulence/CPL_APP_LAMMPS-DEV.git`

Setup your environment further
------------------------------

Configure environment

   ```bash
   cd CPL_APP_LAMMPS-DEV
   echo "/work/project/project/username/mylammps" > CODE_INST_DIR
   # the following SOURCEME.sh is different from the previous two SOURCEME.sh files above
   source SOURCEME.sh
   cd config; ./enable-packages.sh make; cd ..
   ```

Compile CPL_APP_LAMMPS-DEV applications with make
-----------------------------------------------
Run make:

  ```
  make patch-lammps
  make CC=CC LINK=CC
  ```
