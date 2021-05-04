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

Use the previously saved collection that was used for building the central
install of VASP on ARCHER2 and ensure that you update the `LD_LIBRARY_PATH`
environment variable to ensure that the right versions of libraries are used.
The two commands to do this are:

```bash
module restore /work/y07/shared/vasp6/vasp.6.2.0-gcc10-mkl/collection/vasp620_gcc10_mkl212_cpe2103
export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH
```

This should give:

```bash
Unloading /usr/local/share/epcc-module/epcc-module-loader

Warning: Unloading the epcc-setup-env module will stop many
modules being available on the system. If you do this by
accident, you can recover the situation with the command:

        module load /work/y07/shared/archer2-modules/modulefiles-cse/epcc-setup-env

Unloading /work/y07/shared/archer2-modules/modulefiles-cse/epcc-setup-env
Unloading bolt/0.7
Unloading cray-libsci/20.10.1.2
Unloading cray-mpich/8.0.16
Unloading xpmem/2.2.35-7.0.1.0_1.9__gd50fabf.shasta
Unloading perftools-base/20.10.0
Unloading cray-dsmml/0.1.2
Unloading craype-network-ofi
Unloading libfabric/1.11.0.0.233
Unloading craype-x86-rome
Unloading craype/2.7.2
Unloading cce/10.0.4
Unloading cpe-cray
Loading cpe-gnu
Loading craype-x86-rome
Loading libfabric/1.11.0.0.233
Loading craype-network-ofi
Loading xpmem/2.2.35-7.0.1.0_1.9__gd50fabf.shasta
Loading bolt/0.7
Loading /work/y07/shared/archer2-modules/modulefiles-cse/epcc-setup-env
Loading /usr/local/share/epcc-module/epcc-module-loader
Loading cray-dsmml/0.1.3
Loading cray-mpich/8.1.3
Loading craype/2.7.5
Loading perftools-base/21.02.0
Loading gcc/10.2.0
Loading cray-fftw/3.3.8.9
Loading mkl/21.2-2883
```

and your loaded module list should look like:

```bash
Currently Loaded Modulefiles:
 1) cpe-gnu                                                           9) cray-dsmml/0.1.3        
 2) craype-x86-rome                                                  10) cray-mpich/8.1.3        
 3) libfabric/1.11.0.0.233(default)                                  11) craype/2.7.5            
 4) craype-network-ofi                                               12) perftools-base/21.02.0  
 5) xpmem/2.2.35-7.0.1.0_1.9__gd50fabf.shasta(default)               13) gcc/10.2.0              
 6) bolt/0.7                                                         14) cray-fftw/3.3.8.9       
 7) /work/y07/shared/archer2-modules/modulefiles-cse/epcc-setup-env  15) mkl/21.2-2883           
 8) /usr/local/share/epcc-module/epcc-module-loader      
```

Create makefile.include
-----------------------

The new build process for VASP (introduced from version 5.4.1) requires the
correct options to be set in makefile.include in the root directory of the
source distribution.

The makefile.include used for the Intel compilers on ARCHER can be downloaded from:

* [6.2.0_makefile.include.ARCHER2_GCC_MKL_omp](6.2.0_makefile.include.ARCHER2_GCC_MKL_omp)

The  build on ARCHER uses:

* Intel oneAPI MKL for linear algebra
* FFTW 3 for FFT's

You should copy this file to the root directory of the VASP source distribution
and then rename it to "makefile.include":

```bash
cp 6.2.0_makefile.include.ARCHER2_GCC_MKL_omp makefile.include
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
module restore /work/y07/shared/vasp5/vasp.5.4.4.pl2-gcc10-mkl-cpe2103/collection/vasp544-gcc10-mkl
export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH
```
