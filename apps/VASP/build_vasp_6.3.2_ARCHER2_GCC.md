Instructions for compiling VASP 6.3.x for ARCHER2 using GCC compilers
=====================================================================

These instructions are for compiling VASP 6.3.x on [ARCHER2](https://www.archer2.ac.uk)
using the GCC compilers including the use of OpenMP

We assume that you have obtained the VASP source code from the VASP website along
with any relevant patches.

Unpack the VASP source code and apply patches
---------------------------------------------

Unpack the source

```bash
tar -xvf vasp.6.3.2.tar.gz
```

Setup correct modules
---------------------

```bash
module load PrgEnv-gnu
module load cray-libsci/21.08.1.2
module load cray-fftw/3.3.8.13
module load cray-hdf5-parallel/1.12.1.1
```

The loaded module list when these instructions were written was:

```bash
Currently Loaded Modules:
  1) gcc/10.2.0        4) perftools-base/21.02.0                      7) epcc-setup-env    10) cray-libsci/21.08.1.2        13) cray-ucx/2.7.0-1
  2) craype/2.7.6      5) xpmem/2.2.40-7.0.1.0_2.7__g1d7a24d.shasta   8) load-epcc-module  11) cray-fftw/3.3.8.13           14) craype-network-ucx
  3) craype-x86-rome   6) bolt/0.8    
```

Create makefile.include
-----------------------

The new build process for VASP (introduced from version 5.4.1) requires the
correct options to be set in makefile.include in the root directory of the
source distribution.

The makefile.include used for the GCC compilers on ARCHER2 can be downloaded from:

* [6.3.2_makefile.include.ARCHER2_GCC_omp](6.3.2_makefile.include.ARCHER2_GCC_omp)

This build uses:

* HPE Cray LibSci for linear algebra
* FFTW 3 for FFT
* HDF5

You should copy this file to the root directory of the VASP source distribution
and then rename it to "makefile.include":

```bash
cp 6.3.2_makefile.include.ARCHER2_GCC_omp makefile.include
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



