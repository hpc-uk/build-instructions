Instructions for compiling CASTEP 22.1.1 for ARCHER2 using GCC compilers
=========================================================================

These instructions are for compiling CASTEP 22.1.1 on [ARCHER2](https://www.archer2.ac.uk)
using the GCC compilers. ARCHER2 is an HPE Cray EX supercomputer with two AMD 7742 64-core
processors per node and the HPE Cray Slingshot interconnect.

We assume that you have obtained the CASTEP source code from the UKCP developers.

Unpack the CASTEP source code
-----------------------------

Unpack the source

```bash
tar -xvf castep-22.11.tar.gz 
```

Setup correct modules
---------------------

Setup the GCC compilers and load the FFTW library module:

```bash
module load PrgEnv-gnu
module load cray-fftw/3.3.8.11
```

Modules loaded at build time for ARCHER2 central module:

```
  1) gcc/10.2.0
  2) craype/2.7.6                                            
  3) craype-x86-rome
  4) libfabric/1.11.0.4.71
  5) craype-network-ofi
  6) perftools-base/21.02.0 
  7) xpmem/2.2.40-7.0.1.0_2.7__g1d7a24d.shasta
  8) cray-mpich/8.1.4
  9) cray-libsci/21.04.1.1
  10) bolt/0.8
  11) epcc-setup-env
  12) load-epcc-module
  13) PrgEnv-gnu/8.0.0
  14) cray-fftw/3.3.8.11
```

Edit the Makefile to set options
--------------------------------

Switch to the main CASTEP directory

```bash
cd castep-22.11
```

Edit `Makefile` and set the following options

```
COMMS_ARCH := mpi
FFT := fftw3
BUILD := fast
MATHLIBS := scilib
```

Build CASTEP
------------

Build CASTEP using the following commands:

```bash
unset CPU
CC=cc CASTEP_ARCH=linux_x86_64_gfortran10-XT make -j8 clean
CC=cc CASTEP_ARCH=linux_x86_64_gfortran10-XT make -j8
```

The install process will ask for the path to the BLAS and LAPACK libraries - just
leave this blank.

You will also be asked for the path to FFTW; just leave this blank as the compiler 
wrapper scripts automatically deal with this.

Install CASTEP
--------------

To install the binaries in a specified directory use:

```bash
make -j8 INSTALL_DIR=/work/t01/t01/auser/software/CASTEP/22.11-gcc/bin install
```

If you wish to simply install into the `bin/` directory in the CASTEP source
tree you can simply use:

```bash
make -j8 install
```

The built binary is called `castep.mpi`.

