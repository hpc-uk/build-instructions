Instructions for compiling VASP 5.4.4 for ARCHER2 using GCC compilers
====================================================================

These instructions are for compiling VASP 5.4.4 on [ARCHER2](https://www.archer2.ac.uk)
using the GCC compilers.

We assume that you have obtained the VASP source code from the VASP website along
with any relevant patches.

Unpack the VASP source code and apply patches
---------------------------------------------

Unpack the source

```bash
tar -xvf vasp.5.4.4.pl2.tar.gz
```

Apply any patches according to the instructions on the VASP website.

Setup correct modules
---------------------

Load the GCC programming environment, switch to older GCC version (GCC 10 fails to build
VASP successfully) and load the FFTW library module:

```bash
module restore PrgEnv-gnu
module swap gcc gcc/9.3.0
module load cray-fftw
```

Create makefile.include
-----------------------

The new build process for VASP (introduced for version 5.4.1) requires the
correct options to be set in makefile.include in the root directory of the
source distribution.

The makefile.include used for the GCC compilers on ARCHER can be downloaded from:

* [5.4.4_makefile.include.ARCHER2_GCC](5.4.4_makefile.include.ARCHER2_GCC)

The GCC build on ARCHER2 uses:

* Cray LibSci for linear algebra
* FFTW for FFT's

You should copy this file to the root directory of the VASP source distribution
and then rename it to "makefile.include":

```bash
mv 5.4.4_makefile.include.ARCHER2_GCC makefile.include
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

