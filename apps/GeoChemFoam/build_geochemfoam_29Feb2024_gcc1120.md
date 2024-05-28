Building GeoChemFoam on ARCHER2 (GCC 10.2.0)
====================================================

These instructions are for building GeoChemFoam-v5.0 on ARCHER2 using the GNU compilers.

Download GeoChemFOAM-5.0
------------------------
GeoChemFoam-5.0 uses the ESI OpenCFD Release OpenFOAM-v2212. 

Change to  the expected directory in your work folder, e.g.,

   `cd /work/y23/shared/gcfoam`

Then clone version 5.0 of GeoChemFOAM from the GitHub repository:

   `git clone https://github.com/GeoChemFoam/GeoChemFoam-5.0`

Setup your environment
----------------------

Load the correct modules:

   ```bash
   module load openfoam/com/v2212
   ```

Update GeoChemFOAM-5.0/etc/bashrc 
---------------------------------
Edit their etc/bashrc file and change lines #13 and #14 from

   ```bash
   export FOAM_INST_DIR=/usr/lib/openfoam
   source /usr/lib/openfoam/openfoam2212/etc/bashrc
   ```

to read

   ```bash
   export FOAM_INST_DIR=$FOAM_INSTALL_DIR
   source $FOAM_INSTALL_DIR/etc/bashrc
   ```
   
We also change one further line, namely line #4, from

   ```bash
   GCFOAM_DIR=$HOME/works/GeoChemFoam-5.0
   ```

to read

   ```bash
   GCFOAM_DIR=/work/y23/shared/gcfoam/GeoChemFoam-5.0
   ```

Compile CPL_APP_OPENFOAM applications with make
-----------------------------------------------
First, souce the GeoChemFoam bashrc file:

   ```bash
    source /work/y23/shared/gcfoam/GeoChemFoam-5.0/etc/bashrc
   ```

then run make:

   ```bash
  ./Allwmake
  ./checkInstall.sh
  ```

where checkInstall.sh will generate the message

   ```bash
  `Installation successful`
   ```

The make process can be quite verbose: all warnings can be safely ignored.

Create local module-related bashrc
----------------------------------
Lastly, create a file named $GCFOAM_DIR/etc/bashrc_archer2 with the following contents

   ```bash
   # .bashrc
   source $FOAM_INSTALL_DIR/etc/bashrc
   source $GCFOAM_DIR/ThirdParty/bashrc
   ```

which is required by batch scripts that employ this central installation.

