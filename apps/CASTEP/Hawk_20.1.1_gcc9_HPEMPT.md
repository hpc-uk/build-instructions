Instructions for compiling CASTEP 20.1.1 for Hawk using GCC 9.2
===============================================================

These instructions are for compiling CASTEP 20.1.1 on [Hawk](https://www.hlrs.de/systems/hpe-apollo-hawk/)
using the GCC 9.2 compilers and HPE MPT.

We assume that you have obtained the CASTEP source code from the UKCP developers.

Unpack the CASTEP source code
-----------------------------

Unpack the source

```bash
tar -xvf CASTEP-20.11.tar.gz 
```

Setup correct modules
---------------------

Load the required modules:

```bash
module load mkl/19.1.0
```

both `gcc/9.2.0` and `mpt/2.23` should be loaded by default.

Edit the Makefile to set options
--------------------------------

Switch to the main CASTEP directory

```bash
cd CASTEP-20.11
```

Edit `Makefile` and set the following options

```
COMMS_ARCH := mpi
FFT := mkl
BUILD := fast
MATHLIBS := mkl
```

Build CASTEP
------------

Build CASTEP using the following commands:

```bash
unset CPU
make -j8 ARCH=linux_x86_64_gfortran clean
make -j8 ARCH=linux_x86_64_gfortran
```

The install process will ask for the path to the BLAS and LAPACK libraries; just
leave this blank.

You will also be asked for the path to FFTW; just leave this blank.

Install CASTEP
--------------

If you wish to install into the `bin/` directory in the CASTEP source
tree you can use:

```bash
make -j8 install
```

The built binary is called `castep.mpi`.
