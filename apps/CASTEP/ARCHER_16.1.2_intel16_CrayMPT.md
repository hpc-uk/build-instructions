Instructions for compiling CASTEP 16.1.2 for ARCHER using Intel 16 compilers
============================================================================

These instructions are for compiling CASTEP 16.1.2 on ARCHER (Intel Ivy Bridge processors)
using the Intel 16 compilers.

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
module load fftw/3.3.4.10
module load craype-hugepages2M
```

Edit the Makefile to set options
--------------------------------

Switch to the main CASTEP directory

```bash
cd CASTEP-16.1.2
```

Edit `Makefile` and set the following options

```
COMMS_ARCH := mpi
FFT := fftw3
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
make -j8 CASTEP_ARCH=linux_x86_64_ifort16-XC clean
make -j8 CASTEP_ARCH=linux_x86_64_ifort16-XC
```

The install process will ask for the path to the BLAS and LAPACK libraries. Use the path
you found above with `/lib` appended to the end, i.e.:

```
/opt/intel/parallel_studio_xe_2016_ce_u2/compilers_and_libraries_2016.2.181/linux/mkl/lib
```

You will also be asked for the path to FFTW; just leave this blank as the compiler 
wrapper scripts automatically deal with this.

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
