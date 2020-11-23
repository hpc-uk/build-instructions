Instructions for compiling CASTEP 16.1.1 for Cirrus using Intel 17 compilers
============================================================================

These instructions are for compiling CASTEP 16.1.1 on Cirrus (http://www.cirrus.ac.uk) using the Intel 17 compilers
and HPE MPT.

We assume that you have obtained the CASTEP source code from the UKCP developers.

Unpack the CASTEP source code
-----------------------------

Unpack the source

```bash
tar -xvf CASTEP-16.11.tar.gz 
```

Setup correct modules
---------------------

Load the FFTW 3 module:

```bash
module load intel-compilers-17
module load intel-cmkl-17 
module load mpt
module load fftw-3.3.5-intel-17.0.2-dxt2dzn
```

Edit the Makefile to set options
--------------------------------

Switch to the main CASTEP directory

```bash
cd CASTEP-16.11
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
ARCH := linux_x86_64_ifort17
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
make -j8 CASTEP_ARCH=linux_x86_64_ifort17 clean
make -j8 CASTEP_ARCH=linux_x86_64_ifort17
```

The install process will ask for the path to the BLAS and LAPACK libraries. Use the path
you found above with `/lib/intel64` appended to the end, i.e.:

```
/opt/intel/parallel_studio_xe_2017_ce_u2/compilers_and_libraries_2016.2.181/linux/mkl/lib/intel64
```

You will also be asked for the path to FFTW; just leave this blank.

Install CASTEP
--------------

To install the binaries in a specified directory use:

```bash
make -j8 INSTALL_DIR=/lustre/home/y07/castep/16.1.1-intel/bin install
```

If you wish to simply install into the `bin/` directory in the CASTEP source
tree you can simply use:

```bash
make -j8 install
```

The built binary is called `castep.mpi`.
