Instructions for compiling VASP 6.2.0 for ARCHER2 using GCC compilers
=====================================================================

These instructions are for compiling VASP 6.2.0 on [ARCHER2](https://www.archer2.ac.uk)
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

Load the GCC compilers and load the FFTW library module:

```bash
module restore PrgEnv-gcc
module load cray-fftw
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
* FFTW for FFT's

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

