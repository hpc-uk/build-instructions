Instructions for compiling VASP 5.4.4 for Cirrus using Intel compilers
====================================================================

These instructions are for compiling VASP 5.4.4 on [Cirrus](https://www.cirrus.ac.uk) using the Intel compilers.

We assume that you have obtained the VASP source code from the VASP website along
with any relevant patches.

Unpack the VASP source code and apply patches
---------------------------------------------

Unpack the source

```bash
tar -xvf vasp.5.4.4.tar.gz
```

Apply any patches according to the instructions on the VASP website.

Setup correct modules
---------------------

Load the Intel compilers, HPE MPT MPI library and the FFTW library modules:

```bash
module load intel-compilers-19
module load mpt
module load fftw/3.3.9-intel19-mpt220
```

Create makefile.include
-----------------------

The build process for VASP (introduced for version 5.4.1) requires the
correct options to be set in `makefile.include` in the root directory of the
source distribution.

The makefile.include used for the Intel 19 compilers on Cirrus can be downloaded from:

* [5.4.4_makefile.include.Cirrus_Intel](5.4.4_makefile.include.Cirrus_Intel)

The  build on Cirrus uses:

* Intel MKL for linear algebra
* FFTW for FFT's

You should copy this file to the root directory of the VASP source distribution
and then rename it to "makefile.include":

```bash
mv 5.4.4_makefile.include.Cirrus_Intel makefile.include
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

