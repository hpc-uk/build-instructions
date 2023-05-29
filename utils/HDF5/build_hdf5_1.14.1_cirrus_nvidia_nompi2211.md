Instructions for compiling HDF5 1.14.1-2 with CUDA-aware OpenMPI
================================================================

These instructions are known to work successfully for HDF5 1.14.1-2 with GCC Compilers 8.2.0, OpenMPI 4.1.4-CUDA, and CUDA 11.8 on [Cirrus](https://www.cirrus.ac.uk/) (a SGI ICE XA system).
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

Load the OpenMPI module and the NVidia compiler module, that also loads GCC.

```bash
module load openmpi/4.1.4-cuda-11.8
module load nvidia/nvhpc-nompi/22.11
```

Edit the `./fortran/testpar/ptest.f90` file
-------------------------------------------

Delete the line that reads `USE MPI` and add `INCLUDE "mpif.h"` immediately after the `IMPLICIT NONE` statement.

Configure the build
-------------------

Build with MPI-IO and Fortran versions enabled:

```bash
export CC=/mnt/lustre/indy2lfs/sw/nvidia/hpcsdk-2211/Linux_x86_64/22.11/compilers/bin/nvc
export CXX=/mnt/lustre/indy2lfs/sw/nvidia/hpcsdk-2211/Linux_x86_64/22.11/compilers/bin/nvc++
export FC=mpif90

./configure --prefix=/mnt/lustre/indy2lfs/sw/hdf5parallel/1.14.1-2-cuda11.8-ompi4.1.4 --enable-parallel --enable-fortran --enable-build-mode=production CFLAGS="-fPIC -lmpi -I${MPI_HOME}/include" CXXFLAGS="-fPIC -lmpi -I${MPI_HOME}/include" FCFLAGS="-fPIC -lmpi -I${MPI_HOME}/include" LDFLAGS="-L${MPI_HOME}/lib"
```

Build and Install
-----------------

```bash
make -j 8
make -j 8 install
make clean
```
