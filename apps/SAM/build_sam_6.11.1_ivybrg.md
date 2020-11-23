Instructions for compiling SAMS 6.11.1 for ARCHER using Intel compilers
=======================================================================

These instructions are for compiling SAMS 6.11.1 on ARCHER (Intel Ivy Bridge processors) using the Intel compilers.

We assume that you have obtained the SAMS source code from the SAMS developers.

Setup correct modules
---------------------

Switch to the Intel compilers and load the NetCDF library module:

```bash
module swap PrgEnv-cray PrgEnv-intel
module load cray-netcdf
```

Update the SRC/cstuff.c file
----------------------------

The SRC/cstuff.c file is missing the include of a standard C library (stdlib.h).
Edit the file SRC/stuff.c, find the lines

```c
#include <math.h>
#include <stdio.h>
```

and add the extra library to give:

```c
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
```

Update Makefile
---------------

Makefile needs to be edited to set the correct options for building on ARCHER.

Edit Makefile and find the line:

```make
PLATFORM := $(shell uname -s)
```

Change this to:

```make
PLATFORM := CrayXC
```

Now you need to add the section with CrayXC options. Add the following lines 
directly below the PLATFORM line you just edited

```make
#----------------------------------------------------------------------
# Cray XC CEL compute node, ARCHER, Intel Compiler
##

 ifeq ($(PLATFORM),CrayXC)

 FF77 = ftn -c -fixed -extend_source
 FF90 = ftn -c -free
 CC = cc -c -DFORTRANUNDERSCORE


 FFLAGS = -g -O2
 LD = ftn

 endif
```

Update Build script
-------------------

Edit the file Build, find the line:

```csh
setenv GNUMAKE 'gnumake -j8'
```

and change this to:

```csh
setenv GNUMAKE 'gmake'
```

Compile the program
-------------------

Compile SAMS with:

```bash
rm OBJ/*
./Build
```
