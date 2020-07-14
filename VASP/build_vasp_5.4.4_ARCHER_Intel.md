Instructions for compiling VASP 5.4.4 for ARCHER using Intel compilers
====================================================================

These instructions are for compiling VASP 5.4.4 on ARCHER (Intel Ivy Bridge processors) using the Intel compilers.

We assume that you have obtained the VASP source code from the VASP website along
with any relevent patches.

Unpack the VASP source code and apply patches
---------------------------------------------

Unpack the source

```bash
tar -xvf vasp.5.4.4.tar.gz
```

Apply any patches according to the instructions on the VASP webiste.

Setup correct modules
---------------------

Switch to the Intel compilers and load the FFTW library module:

```bash
module swap PrgEnv-cray PrgEnv-intel
module load fftw
```

Create makefile.include
-----------------------

The new build process for VASP (introduced for version 5.4.1) requires the
correct options to be set in makefile.include in the root directory of the
source distribution.

The makefile.include used for the Intel compilers on ARCHER can be downloaded from:

* [5.4.4_makefile.include.crayxc_intel](5.4.4_makefile.include.crayxc_intel)

The  build on ARCHER uses:

* Intel MKL for linear algebra
* FFTW for FFT's

You should copy this file to the root directory of the VASP source distribution
and then rename it to "makefile.include":

```bash
mv 5.4.4_makefile.include.crayxc_intel makefile.include
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

