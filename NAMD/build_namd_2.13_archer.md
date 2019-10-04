Instructions for compiling NAMD 2.13 + Plumed for ARCHER XC30
=============================================================

These instructions are for compiling NAMD 2.13 on ARCHER XC30 (Xeon) using the Intel compilers.

These instructions are based on those produced by the BlueWaters team: https://bluewaters.ncsa.illinois.edu/namd

Download and unpack NAMD
------------------------

First download the NAMD source from: http://www.ks.uiuc.edu/Development/Download/download.cgi?PackageName=NAMD
and transfer to the ARCHER system.

Unpack the source

```bash
tar -xvf NAMD_2.13_Source.tar.gz
```

Setup modified TCL
------------------

Download, unpack and link:

```bash
cd NAMD_2.13_Source
wget http://www.ks.uiuc.edu/Research/namd/libraries/tcl8.5.9-crayxe-threaded.tar.gz
tar -xvf tcl8.5.9-crayxe-threaded.tar.gz
ln -s tcl8.5.9-crayxe-threaded ./tcl
```

Setup correct modules
---------------------

```bash
module swap PrgEnv-cray PrgEnv-intel
module load fftw
module load rca
module load craype-hugepages8M
module load gcc
```

Extract and Build Charm++
--------------------------

```bash
tar -xvf charm-6.8.2.tar
cd charm-6.8.2
./build charm++ gni-crayxe smp persistent -j4 --with-production
cd ..
```


Build NAMD
----------

```bash
./config CRAY-XC-intel --with-fftw --with-fftw3 --fftw-prefix $FFTW_DIR/.. --charm-arch gni-crayxe-persistent-smp
cd CRAY-XC-intel/
gmake -j4
```

This will create the executable `namd2` in the CRAY-XC-intel directory.


Patching NAMD with PLUMED
-------------------------
```bash
module load plumed2/2.5.2-parallel
```
Submit an interactve job on the short queue
```bash
qsub -IVl select=1,walltime=0:20:0 -q short -A budget
```
You must set $TMPDIR to point to a location on /work so that the plumed executable can create files:
```bash
TMPDIR=/work/y07/y07/cse
```
Apply the PLUMED patch to Gromacs

```bash
cd NAMD_2.13_Source
aprun -n 1 plumed_mpi-patch -p
```
Once the patch has been applied, NAMD needs to be recompiled.


Recompiling NAMD after applying PLUMED2 patch
---------------------------------------------
```bash
export CRAYPE_LINK_TYPE=dynamic

cd CRAY-XC-intel
gmake -j 4
```
