Instructions for compiling serial CASTEP 16.1.2 for ARCHER PP nodes using Intel 16 compilers
============================================================================================

These instructions are for compiling serial CASTEP 16.1.2 on ARCHER for the post-processing
nodes (Intel Westmere processors) using the Intel 16 compilers.

We assume that you have obtained the CASTEP source code from the UKCP developers.

Unpack the CASTEP source code
-----------------------------

Unpack the source

```bash
tar -xvf CASTEP-16.1.2.tar.gz 
```

Setup correct modules
---------------------

Switch to the Intel 16 compilers and load the FFTW library module:

```bash
module swap PrgEnv-cray PrgEnv-intel
module swap intel intel/16.0.2.181 
```

Edit the Makefile to set options
--------------------------------

Switch to the main CASTEP directory

```bash
cd CASTEP-16.1.2
```

Edit `Makefile` and set the following options

```
COMMS_ARCH := serial
FFT := mkl
BUILD := fast
MATHLIBS := mkl10
```

Build CASTEP
------------

Find the path to the MKL libraries (needed for compile step)

```bash
echo $MKLROOT
/opt/intel/parallel_studio_xe_2016_ce_u2/compilers_and_libraries_2016.2.181/linux/mkl
```

Build CASTEP using the following commands:

```bash
unset CPU
make -j8 ARCH=linux_x86_64_ifort16 clean
make -j8 ARCH=linux_x86_64_ifort16
```

The install process will ask for the path to the BLAS and LAPACK libraries. Use the path
you found above with `/lib` appended to the end, i.e.:

```
/opt/intel/parallel_studio_xe_2016_ce_u2/compilers_and_libraries_2016.2.181/linux/mkl/lib
```

You will also be asked for the path to the MKL FFT libraries; use the same path as for the
BLAS and LAPACK libraries, e.g.:

```
/opt/intel/parallel_studio_xe_2016_ce_u2/compilers_and_libraries_2016.2.181/linux/mkl/lib
```

Install CASTEP
--------------

To install the binaries in a specified directory use:

```bash
make -j8 ARCH=linux_x86_64_ifort16 INSTALL_DIR=/home/y07/y07/castep/16.1.2-serial-intel/bin install
```

If you wish to simply install into the `bin/` directory in the CASTEP source
tree you can simply use:

```bash
make -j8 ARCH=linux_x86_64_ifort16 install
```

