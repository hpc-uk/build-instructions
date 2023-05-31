Instructions for compiling HDF5 1.14.1-2 with Intel MPI 19
==========================================================

These instructions are known to work successfully for HDF5 1.14.1-2 with GCC Compilers 8.2.0, and Intel MPI 19 [Cirrus](https://www.cirrus.ac.uk/) (a SGI ICE XA system).
They build parallel HDF5.

Download and unpack HDF5
------------------------

Download HDF5 source from [HDF5 Downloads](https://www.hdfgroup.org/downloads/hdf5/) and then unpack

```bash
tar -xvf hdf5-1.14.1-2.tar.gz
```

Create install directory and setup environment
----------------------------------------------

Move to the source directory and create an install directory:

```bash
cd hdf5-1.14.1-2
```

Load the gcc and intel MPI modules

```bash
module load gcc/8.2.0
module load intel-mpi-19
```

Configure the build
-------------------

Build with MPI-IO and Fortran versions enabled:

```bash
./configure --prefix=/mnt/lustre/indy2lfs/sw/hdf5parallel/1.14.1-2-cuda11.8-ompi4.1.4 --enable-parallel --enable-fortran --enable-build-mode=production"
```

Build and Install
-----------------

```bash
make -j 8
make -j 8 install
make clean
```
