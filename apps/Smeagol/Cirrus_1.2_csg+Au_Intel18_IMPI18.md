Instructions for compiling Smeagol 1.2_csg+Au for Cirrus using Intel 18 compilers
==================================================================================

These instructions are for compiling Smeagol 1.2_csg+Au on Cirrus (http://www.cirrus.ac.uk) using the Intel 18 compilers and Intel MPI 18.

We assume that you have obtained the Smeagol source code from the developers and the Siesta
1.3f1 source from the Siesta developers.

Unpack the source code
----------------------

Unpack the Siest 1.3f source

```bash
tar -xvf siesta-1.3f1.tgz
```

Change the name of the Siesta directory to `smeagol-1.2_csg+Au`:

```bash
mv siesta-1.3f1 smeagol-1.2_csg+Au
```

Now unpack the Smeagol source code - this will overwrite some files and directories in the
Siesta distribution and add some additional files:

```bash
tar -xvf smeagol.tar.gz
```

Setup correct modules and environment
-------------------------------------

Load the required modules:

```bash
module load intel-compilers-18/18.05.274
module load intel-mpi-18/18.0.5.274
module load intel-cmkl-18/18.0.5.274
```

and set the compiler environment variables:

```bash
export CC=mpiicc
export LD=mpiifort
```

Create `arch.make` file to set compile options
----------------------------------------------

Switch to the Smeagol source directory:

```bash
cd smeagol-1.2_csg+Au/Src
```

and create `arch.make` with the following contents

```
SIESTA_ARCH=intel-mkl
#
# Cirrus, UK Tier-2 national HPC facility: https://www.cirrus.ac.uk
#
# Intel 18 compiler, Intel MPI 18, Intel MKL
#
FC=mpiifort 
#
FFLAGS=-mkl=sequential -w -mp -tpp5 -O3
FFLAGS_DEBUG= -g 
LDFLAGS=
COMP_LIBS=
RANLIB=echo
#
NETCDF_LIBS=
NETCDF_INTERFACE=
DEFS_CDF=
#
MPI_INTERFACE=libmpi_f90.a
MPI_INCLUDE=/lustre/sw/intel/compilers_and_libraries_2018.5.274/linux/mpi/include64
DEFS_MPI=-DMPI
#
GUIDE=
LAPACK=
BLAS=${MKLROOT}/lib/intel64/libmkl_scalapack_lp64.a -Wl,--start-group ${MKLROOT}/lib/intel64/libmkl_intel_lp64.a ${MKLROOT}/lib/intel64/libmkl_sequential.a ${MKLROOT}/lib/intel64/libmkl_core.a ${MKLROOT}/lib/intel64/libmkl_blacs_intelmpi_lp64.a -Wl,--end-group -lpthread -lm -ldl
#G2C=/usr/lib/gcc-lib/i386-redhat-linux/2.96/libg2c.a
LIBS=$(LAPACK) $(BLAS) $(G2C) $(GUIDE)  -lpthread 
SYS=bsd
DEFS= $(DEFS_CDF) $(DEFS_MPI)

EXT_LIBS=extlibs.a

EXEC=smeagol.x
#
.F.o:
	$(FC) -c $(FFLAGS)  $(DEFS) $<
.f.o:
	$(FC) -c $(FFLAGS)   $<
.F90.o:
	$(FC) -c $(FFLAGS)  $(DEFS) $<
.f90.o:
	$(FC) -c $(FFLAGS)   $<
#
```

You can also [download this file](cirrus_intel18_arch.make)

Edit the `Makefile`
------------

Edit the `Makefile` to make sure the Smeagol LINPACK routines are included. Make sure
the following lines (lines 164-168 in our version of the `Makefile`) are uncommented:

```bash
LINPACK=linpack.smeagol.a
$(LINPACK):
        (cd ../linpack; $(FC) -c $(FFLAGS) $(BGPLINPACKOPTS)  $(TRANSPORTFLAGS) *.f; \
        ar -rv linpack.smeagol.a *.o; \
        mv linpack.smeagol.a ../Src)
```

Build Smeagol
-------------

You should now be able to build Smeagol with (from the `Src` directory):

```bash
make clean
make
```

The Smeagol binary will be in the `Src` directory and called `smeagol.x`. 

Notes
-----

When running Smeagol, you will need to include the lines:

```bash
module load intel-compilers-18/18.05.274
module load intel-mpi-18/18.0.5.274
```

in your job submission script.
