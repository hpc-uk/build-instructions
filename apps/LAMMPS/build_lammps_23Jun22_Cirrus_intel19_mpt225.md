Building LAMMPS on Cirrus (Intel 19, SGI MPT 2.25)
===================================================

These instructions are for building LAMMPS on Cirrus (SGI/HPE ICE XA, Intel Broadwell)
using the Intel 19 compilers and MPI from SGI MPT 2.25.

Download LAMMPS
---------------

Clone the latest stable version of LAMMPS from the GitHub repository:

```bash
   git clone -b stable https://github.com/lammps/lammps.git mylammps
 ```

Setup your environment
----------------------

Load the correct modules:

```bash
   module load mpt/2.25
   module load fftw/3.3.8-intel19
   module load cmake
 ```

MPI Version
-----------

Make and go into a build directory:

```bash
   mkdir mylammps/build; cd mylammps/build
 ```

Build using:

```bash
  export MPICC_CC=icc
  export MPICXX_CXX=icpc
  cmake -DCMAKE_CXX_COMPILER=mpicxx -DBUILD_MPI=on -D FFT=FFTW3     \
        -D PKG_ASPHERE=yes -D PKG_BODY=yes -D PKG_CLASS2=yes        \
        -D PKG_COLLOID=yes -D PKG_COMPRESS=yes -D PKG_CORESHELL=yes \
        -D PKG_DIPOLE=yes -D PKG_GRANULAR=yes -D PKG_MC=yes         \
        -D PKG_MISC=yes -D PKG_KSPACE=yes -D PKG_MANYBODY=yes       \
        -D PKG_MOLECULE=yes -D PKG_MPIIO=yes -D PKG_OPT=yes         \
        -D PKG_PERI=yes -D PKG_QEQ=yes -D PKG_SHOCK=yes             \
        -D PKG_SRD=yes -D PKG_RIGID=yes                             \
        -DCMAKE_INSTALL_PREFIX=<INSTALL_PATH>                       \
        ../cmake/
  make -j 8
  make install
```
