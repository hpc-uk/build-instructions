Instructions for compiling CASTEP 18.1.0 for Tesseract using Intel 18 compilers
============================================================================

These instructions are for compiling CASTEP 18.1.0 on Tesseract (http://www.cirrus.ac.uk) using the Intel 17 compilers
and HPE MPT.

We assume that you have obtained the CASTEP source code from the UKCP developers.

Unpack the CASTEP source code
-----------------------------

Unpack the source

```bash
tar -xvf CASTEP-18.1.tar.gz 
```

Setup correct modules
---------------------

Load the required modules:

```bash
module load intel-tools-18
module load intel-mpi-18
```

Create the arch file for Intel MPI
----------------------------------

CASTEP 18.1.0 does not contain a configuration file for using Intel MPI so this
needs to be created. Switch to the platform files directory and copy the base
Linux Intel 17 file:

```bash
cd CASTEP-18.1/obj/platforms
cp linux_x86_64_ifort17.mk linux_x86_64_ifort18-IMPI.mk
```

Edit `linux_x86_64_ifort18-IMPI.mk` to set the MPI compilers to pick up the 
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
cd CASTEP-18.1
```

Edit `Makefile` and set the following options

```
COMMS_ARCH := mpi
FFT := mkl
BUILD := fast
MATHLIBS := mkl10
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
make -j8 ARCH=linux_x86_64_ifort18-IMPI clean
make -j8 ARCH=linux_x86_64_ifort18-IMPI
```

The install process will ask for the path to the BLAS and LAPACK libraries. Use the path
you found above with `/lib/intel64` appended to the end, i.e.:

```
/lustre/sw/intel/compilers_and_libraries_2017.2.174/linux/mkl/lib/intel64
```

You will also be asked for the path to FFTW; just leave this blank.

Install CASTEP
--------------

To install into the `bin/` directory in the CASTEP source
tree you use:

```bash
make -j8 ARCH=linux_x86_64_ifort18-IMPI install
```

The built binary is called `castep.mpi`.
