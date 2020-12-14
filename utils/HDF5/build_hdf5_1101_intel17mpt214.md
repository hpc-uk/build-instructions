Instructions for compiling HDF5 1.10.1 with Intel Compilers 
===========================================================

These instructions are known to work successfully for HDF5 1.10.1 with
Intel Compilers 17 and MPT 2.14 on [Cirrus](http://www.epcc.ed.ac.uk/cirrus) (a
SGI ICE XA system). They build parallel HDF5.

Download and unpack HDF5
------------------------

Download HDF5 source from [HDF5 Downloads](https://www.hdfgroup.org/downloads/hdf5/) and then unpack

```bash
tar -xvf hdf5-1.10.1.tar.gz
```

Create install directory and setup environment
----------------------------------------------

Move to the source directory and create an install directory:

```bash
cd hdf5-1.10.1
mkdir ../1.10.1-intel17-mpt214
```

Load the MPT (MPI) module and the Intel compiler module. Also 
need to set environment variables to pick up the correct compilers:

```bash
module load mpt
module load intel-compilers-17
export MPICC_CC=icc
export MPICXX_CXX=icpc
```

Configure the build
-------------------

Build with MPI-IO and Fortran versions enabled:

```bash
./configure --prefix=/lustre/sw/hdf5/1.10.1-intel17-mpt214 --enable-parallel --enable-fortran --enable-build-mode=production
```

Build and Install
-----------------

```bash
make -j 8
make -j 8 install
```

