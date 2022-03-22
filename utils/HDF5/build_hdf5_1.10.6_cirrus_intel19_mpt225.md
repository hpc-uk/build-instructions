Instructions for compiling HDF5 1.10.6 with Intel Compilers 
===========================================================

These instructions are known to work successfully for HDF5 1.10.6 with
Intel Compilers 19 and MPT 2.25 on [Cirrus](https://www.cirrus.ac.uk/) (a
SGI ICE XA system). They build parallel HDF5.

Download and unpack HDF5
------------------------

Download HDF5 source from [HDF5 Downloads](https://www.hdfgroup.org/downloads/hdf5/) and then unpack

```bash
tar -xvf hdf5-1.10.6.tar.gz
```

Create install directory and setup environment
----------------------------------------------

Move to the source directory and create an install directory:

```bash
cd hdf5-1.10.6
```

Load the MPT (MPI) module and the Intel compiler module. Also 
need to set environment variables to pick up the correct compilers:

```bash
module load mpt/2.25
module load intel-compilers-19
export MPICC_CC=icc
export MPICXX_CXX=icpc
```

Configure the build
-------------------

Build with MPI-IO and Fortran versions enabled:

```bash
./configure --prefix=/scratch/sw/hdf5/1.10.6-intel19-mpt225 --enable-parallel --enable-fortran --enable-build-mode=production
```

Build and Install
-----------------

```bash
make -j 8
make -j 8 install
make clean
```
