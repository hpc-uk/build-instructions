Instructions for compiling SIESTA 4.1-b2 for ARCHER using Intel compilers
=========================================================================

These instructions are for compiling SIESTA 4.1-b2 on ARCHER (Intel Ivy Bridge processors)
using the Intel compilers

Download and Unpack the source code
-------------------------------------------

Download and unpack the source

```bash
wget wget https://launchpad.net/siesta/4.1/4.1-b2/+download/siesta-4.1-b2.tar.gz
tar zxvf siesta-4.1-b2.tar.gz
```

Setup correct modules
---------------------

Switch to the Intel programming environment:

```bash
module swap PrgEnv-cray PrgEnv-intel
```


Configure the build
-------------------

Go into the source build directory and run the setup script


```bash
cd siesta-4.1-b2/Obj
sh ../Src/obj_setup.sh
```

This will create some files for the compilation.  As we are building with
the Intel compilers copy the appropriate make configuration file

```bash
cp intel.make arch.make
```

Edit the arch.make file to set the correct compilers.

```bash
CC = cc
FPP = $(FC) -E -P
FC = ftn
FC_SERIAL = ftn
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

