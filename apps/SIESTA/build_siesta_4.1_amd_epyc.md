Instructions for compiling SIESTA 4.1-b4 for ARCHER2 using GNU compilers
========================================================================

These instructions are for compiling SIESTA 4.1-b4 on ARCHER2 (AMD EPYC
processors) using the GNU compilers

Download and Unpack the source code
-------------------------------------------

Download and unpack the source

```bash
wget wget https://launchpad.net/siesta/4.1/4.1-b4/+download/siesta-4.1-b4.tar.gz
tar zxvf siesta-4.1-b4.tar.gz
```

Setup correct modules
---------------------

Switch to the GNU programming environment:

```bash
module swap PrgEnv-cray PrgEnv-gnu
```


Configure the build
-------------------

Go into the source build directory and run the setup script


```bash
cd siesta-4.1-b4/Obj
sh ../Src/obj_setup.sh
```

This will create some files for the compilation.  As we are building with
the GNU compilers copy the appropriate make configuration file

```bash
cp gfortran.make arch.make
```

Edit the arch.make file to set the correct compilers.

```bash
SIESTA_ARCH = cray-gcc

CC = cc
FPP = $(FC) -E -P -x c
FC = ftn
FC_SERIAL = ftn

FFLAGS = -O2 -fPIC -ftree-vectorize -fallow-argument-mismatch 
```

Ensure that optimised maths libraries will be used in the compilation by editing the arch.make file.

```bash
COMP_LIBS =
```

Enable MPI by editing the arch.make file and adding the following.

```bash
MPI_INTERFACE = libmpi_f90.a
MPI_INCLUDE = .
FPPFLAGS += -DMPI
```

Build the executable using make

```bash
make
```

This should produce the executable (called siesta) in the Obj directory (where you have been compiling the code).

