Instructions for compiling HDF5 1.10.2 with Cray Compilers 
==========================================================

These instructions are known to work successfully for HDF5 1.10.2 with
Cray Compilers on Isambard (a Arm64 system). They build parallel HDF5.

Download and unpack HDF5
------------------------

Download HDF5 source from [HDF5 Downloads](https://www.hdfgroup.org/downloads/hdf5/) and then unpack

```bash
tar -xvf hdf5-1.10.2.tar.gz
```

Create install directory and setup environment
----------------------------------------------

Move to the source directory and create an install directory:

```bash
cd hdf5-1.10.2
mkdir ../1.10.2-cray
```

Configure the build
-------------------

Set the compilers:

```bash
export CC=cc
export CXX=CC
export FC=ftn
```

Build with MPI-IO and Fortran versions enabled:

```bash
./configure --prefix=/home/brx-auser/software/hdf5/1.10.2-cray --enable-parallel --enable-fortran --enable-build-mode=production
```

Build and Install
-----------------

```bash
make -j 8
make -j 8 install
make clean
```

