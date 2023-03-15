Instructions for compiling VASP 6.3.x for Cirrus using Intel20 compilers
==========================================================================

These instructions are for compiling VASP 6.3.x on [Cirrus](https://www.cirrus.ac.uk)
using the Intel compilers including the use of OpenMP

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
module load mpt
module load intel-20.4/compilers
module load intel-20.4/cmkl
```

The loaded module list when these instructions were written was:

```bash
Currently Loaded Modulefiles:
 1) git/2.37.3           2) epcc/utils      3) setup-env       4) mpt/2.25              5) intel-license
 6) gcc/8.2.0(default)   7) intel-20.4/cc   8) intel-20.4/fc   9) intel-20.4/compilers  10) intel-20.4/cmkl
```

Create makefile.include
-----------------------

The new build process for VASP (introduced from version 5.4.1) requires the
correct options to be set in makefile.include in the root directory of the
source distribution.

The makefile.include used for the NVHPC compilers on Cirrus GPU can be downloaded from:

* [6.3.2_makefile.include.Cirrus_Intel](6.3.2_makefile.include.Cirrus_Intel)

You should copy this file to the root directory of the VASP source distribution
and then rename it to "makefile.include":

```bash
cp 6.3.2_makefile.include.Cirrus_Intel makefile.include
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



