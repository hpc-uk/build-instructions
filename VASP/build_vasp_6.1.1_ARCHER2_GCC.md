Instructions for compiling VASP 6.1.1 for ARCHER2 using GCC compilers
=====================================================================

These instructions are for compiling VASP 6.1.1 on [ARCHER2](https://www.archer2.ac.uk)
using the GCC compilers including the use of OpenMP

We assume that you have obtained the VASP source code from the VASP website along
with any relevant patches.

Unpack the VASP source code and apply patches
---------------------------------------------

Unpack the source

```bash
tar -xvf vasp.6.1.1.tar.gz
```

Apply any patches according to the instructions on the VASP website.

Setup correct modules
---------------------

Load the GCC compilers, switch to older GCC (GCC 10 does not compile VASP successfully)
and load the FFTW library module:

```bash
module restore PrgEnv-gcc
module swap gcc gcc/9.3.0
module load cray-fftw
```

Create makefile.include
-----------------------

The new build process for VASP (introduced from version 5.4.1) requires the
correct options to be set in makefile.include in the root directory of the
source distribution.

The makefile.include used for the Intel compilers on ARCHER can be downloaded from:

* [6.1.1_makefile.include.ARCHER2_GCC_omp](6.1.1_makefile.include.ARCHER2_GCC_omp)

The  build on ARCHER uses:

* HPE Cray LibSci for linear algebra
* FFTW for FFT's

You should copy this file to the root directory of the VASP source distribution
and then rename it to "makefile.include":

```bash
mv 6.1.1_makefile.include.ARCHER2_GCC_omp makefile.include
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

