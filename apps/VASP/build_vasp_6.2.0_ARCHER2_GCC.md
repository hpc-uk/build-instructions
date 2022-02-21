Instructions for compiling VASP 6.2.x for ARCHER2 using GCC compilers
=====================================================================

These instructions are for compiling VASP 6.2.x on [ARCHER2](https://www.archer2.ac.uk)
using the GCC compilers including the use of OpenMP

We assume that you have obtained the VASP source code from the VASP website along
with any relevant patches.

Unpack the VASP source code and apply patches
---------------------------------------------

Unpack the source

```bash
tar -xvf vasp.6.2.0.tar.gz
```

Setup correct modules
---------------------

We use the non-default, more recent (21.09) version of the programming environment
on ARCHER2. Setup the GCC compiler environment and FFTW and switch to the more recent
programming environment version. You should also update the `LD_LIBRARY_PATH`
environment variable to ensure that the right versions of libraries are used.
The commands to do all this are:

```bash
module load cpe/21.09
module load PrgEnv-gnu
module load cray-fftw
export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH
```

This should give:

```bash
The following have been reloaded with a version change:
  1) PrgEnv-cray/8.0.0 => PrgEnv-cray/8.1.0     3) cray-libsci/21.04.1.1 => cray-libsci/21.08.1.2     5) craype/2.7.6 => craype/2.7.10
  2) cce/11.0.4 => cce/12.0.3                   4) cray-mpich/8.1.4 => cray-mpich/8.1.9

Lmod is automatically replacing "cce/12.0.3" with "gcc/11.2.0".

Lmod is automatically replacing "PrgEnv-cray/8.1.0" with "PrgEnv-gnu/8.1.0".

Due to MODULEPATH changes, the following have been reloaded:
  1) cray-mpich/8.1.9
```

and your loaded module list should look like:

```bash
Currently Loaded Modules:
  1) cpe/21.09       4) craype-x86-rome         7) cray-dsmml/0.2.1       10) bolt/0.7          13) PrgEnv-gnu/8.1.0
  2) gcc/11.2.0      5) libfabric/1.11.0.4.71   8) cray-mpich/8.1.9       11) epcc-setup-env    14) cray-fftw/3.3.8.11
  3) craype/2.7.10   6) craype-network-ofi      9) cray-libsci/21.08.1.2  12) load-epcc-module   
```

Create makefile.include
-----------------------

The new build process for VASP (introduced from version 5.4.1) requires the
correct options to be set in makefile.include in the root directory of the
source distribution.

The makefile.include used for the Intel compilers on ARCHER2 can be downloaded from:

* [6.2.0_makefile.include.ARCHER2_GCC_omp](6.2.0_makefile.include.ARCHER2_GCC_omp)

The build on ARCHER2 uses:

* HPE Cray LibSci for linear algebra
* FFTW 3 for FFT's

You should copy this file to the root directory of the VASP source distribution
and then rename it to "makefile.include":

```bash
cp 6.2.0_makefile.include.ARCHER2_GCC_omp makefile.include
```

Build VASP
----------

You build all the VASP executables with:

```bash
make all
```

This will produce the following executables in the bin directory:

* `vasp_std` - Multiple k-point version
* `vasp_gam` - GAMMA-point version
* `vasp_ncl` - Non-collinear version

All versions include the additional MD algorithms accessed via the MDALGO keyword.

**Important:** Remember that you will need the following two lines in your job submission
script to ensure that the correct versions of libraries are used at runtime:

```bash
module load cpe/21.09
module load PrgEnv-gnu
module load cray-fftw
export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH
```
