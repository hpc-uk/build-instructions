Instructions for compiling VASP 6.5.x for ARCHER2 using GCC compilers
=====================================================================

These instructions are for compiling VASP 6.5.0 on
[ARCHER2](https://www.archer2.ac.uk)
using the GCC compilers including the use of OpenMP.

We assume that you have obtained the VASP source code from the VASP website
along with any relevant patches.

Unpack the VASP source code and apply patches
---------------------------------------------

Unpack the source

```bash
tar -xvf vasp.6.5.0.tar.gz
```

Setup correct modules
---------------------

```bash
module restore
module load PrgEnv-gnu
module load cray-fftw
module load cray-hdf5-parallel
```

The loaded module list when these instructions were written was:

```
user@ln02:> module list
Currently Loaded Modules:
  1) craype-x86-rome            5) xpmem/2.5.2-2.4_3.30__gd0f7936.shasta   9) gcc/11.2.0         13) cray-libsci/22.12.1.1
  2) libfabric/1.12.1.2.2.0.0   6) bolt/0.8                               10) craype/2.7.19      14) PrgEnv-gnu/8.3.3
  3) craype-network-ofi         7) epcc-setup-env                         11) cray-dsmml/0.2.2   15) cray-fftw/3.3.10.3
  4) perftools-base/22.12.0     8) load-epcc-module                       12) cray-mpich/8.1.23  16) cray-hdf5-parallel/1.12.2.1
```

Create makefile.include
-----------------------

The new build process for VASP (introduced from version 5.4.1) requires the
correct options to be set in makefile.include in the root directory of the
source distribution.

The makefile.include used for the GCC compilers on ARCHER2 can be see at:
```
/work/y07/shared/apps/core/vasp/6/6.5.0/makefiles
```
and is also available as
* [6.5.0_makefile.include.ARCHER2_GCC_omp](6.5.0_makefile.include.ARCHER2_GCC_omp)

This build uses:

* HPE Cray LibSci for linear algebra
* FFTW 3 for FFT
* HDF5
* [libbeef](../../libs/libbeef/)
* Wannier90
* LibXC
* VASP-ML

You should copy this file to the root directory of the VASP source distribution
and then rename it to `makefile.include`, e.g.:

```bash
cp 6.5.0_makefile.include.ARCHER2_GCC_omp makefile.include
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



