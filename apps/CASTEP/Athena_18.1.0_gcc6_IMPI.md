Instructions for compiling CASTEP 18.1.0 for Athena (HPC Mid+) using GCC 6.x compilers
======================================================================================

These instructions are for compiling CASTEP 18.1 on Athena (HPC Mid+) using the GCC 6.x compilers
and Intel MPI 17.

We assume that you have obtained the CASTEP source code from the UKCP developers.

Unpack the CASTEP source code
-----------------------------

Unpack the source

```bash
tar -xvf CASTEP-18.1.tar.gz 
```

Setup correct modules
---------------------

Load the compiler, MPI and MKL modules:

```bash
module load gcc/6.3.0/1
module load intel/mpi/64/2017.2.174
module load intel/mkl/64/2017.2.174
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
/trinity/shared/apps/cv-standard/intel/2017.2.174/compilers_and_libraries_2017.2.174/linux/mkl
```

Build CASTEP using the following commands:

```bash
unset CPU
make -j8 CASTEP_ARCH=linux_x86_64_gfortran6.0 clean
make -j8 CASTEP_ARCH=linux_x86_64_gfortran6.0
```

The install process will ask for the path to the BLAS and LAPACK libraries. Use the path
you found above with `/lib/intel64` appended to the end, i.e.:

```
/trinity/shared/apps/cv-standard/intel/2017.2.174/compilers_and_libraries_2017.2.174/linux/mkl/lib/intel64
```

You will also be asked for the path to MKL FFT, use the same path as for BLAS/LAPACK.

Install CASTEP
--------------

To install into the `bin/` directory in the CASTEP source tree you can use:

```bash
make -j8 install
```

The built binary is called `castep.mpi`.
