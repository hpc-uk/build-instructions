Instructions for compiling CASTEP 17.2.1 for CSD3-Skylake using Intel 16 compilers
============================================================================

These instructions are for compiling CASTEP 17.2,1 on Cirrus (http://www.cirrus.ac.uk) using the Intel 17 compilers
and Intel MPI 17.

We assume that you have obtained the CASTEP source code from the UKCP developers.

Unpack the CASTEP source code
-----------------------------

Unpack the source

```bash
tar -xvf CASTEP-17.21.tar.gz 
```

Setup correct modules
---------------------

Load the FFTW 3 module:

```bash
module load fftw/intel/64/3.3.3
```

Create the arch file for Intel MPI
----------------------------------

CASTEP 17.2.1 does not contain a configuration file for using Intel MPI so this
needs to be created. Switch to the platform files directory and copy the base
Linux Intel 17 file:

```bash
cd CASTEP-17.21/obj/platforms
cp linux_x86_64_ifort17.mk linux_x86_64_ifort17-IMPI.mk
```

Edit `linux_x86_64_ifort17-IMPI.mk` to set the MPI compilers to pick up the 
Intel compilers rather than GCC::

```
ifeq ($(COMMS_ARCH),mpi)
CC  = mpiicc
F90 = mpiifort
```


Edit the Makefile to set options
--------------------------------

Switch to the main CASTEP directory

```bash
cd CASTEP-17.21
```

Edit `Makefile` and set the following options

```
COMMS_ARCH := mpi
FFT := fftw3
BUILD := fast
MATHLIBS := mkl10
```

The architecture detection does not work correctly either so you need to comment out all the
lines set `ARCH` and hard code this:

```
# ifeq ($(origin CASTEP_ARCH),environment)
#   ARCH := $(CASTEP_ARCH)
# else
#   ARCH := $(shell bin/arch)
# endif
ARCH := linux_x86_64_ifort17-IMPI
```

Build CASTEP
------------

Find the path to the MKL libraries (needed for compile step)

```bash
echo $MKLROOT
```

Build CASTEP using the following commands:

```bash
unset CPU
make -j8 CASTEP_ARCH=linux_x86_64_ifort17-IMPI clean
make -j8 CASTEP_ARCH=linux_x86_64_ifort17-IMPI
```

The install process will ask for the path to the BLAS and LAPACK libraries. Use the path
you found above with `/lib/intel64` appended to the end, i.e.:

```
/opt/intel/parallel_studio_xe_2016_ce_u2/compilers_and_libraries_2016.2.181/linux/mkl/lib/intel64
```

You will also be asked for the path to FFTW; just leave this blank.

Install CASTEP
--------------

To install the binaries in a specified directory use:

```bash
make -j8 INSTALL_DIR=/home/y07/y07/castep/16.1.2-intel/bin install
```

If you wish to simply install into the `bin/` directory in the CASTEP source
tree you can simply use:

```bash
make -j8 install
```

The built binary is called `castep.mpi`.
