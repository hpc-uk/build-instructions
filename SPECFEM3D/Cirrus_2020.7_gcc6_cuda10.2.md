Instructions for compiling SPECFEM3D 2020.7 for Cirrus using GCC 6 compilers and CUDA 10.2
===========================================================================================

These instructions are for compiling SPECFEM3D 2020.7 on Cirrus (http://www.cirrus.ac.uk) using the GCC 6 compilers and CUDA 10.2.


Download and Unpack the latest version of SPECFEM3D source code
---------------------------------------------------------------

Download and unpack the source

```bash
git clone --recursive --branch devel https://github.com/geodynamics/specfem3d.git
```

Setup correct modules
---------------------

Load the compiler, zlib and MPI modules

```bash
module load gcc/6.3.0 
module load mpt
module load nvidia/cuda-10.2
module load zlib
```

Configure and build the parallel, double-precision build
--------------------------------------------------------

Create a build directory in the source tree

```bash
./configure --enable-openmp --enable-double-precision --with-cuda=cuda8
```

Note this will build an executable for devices of compute capability 6.0 or higher.

```bash
make -j 8 install
```


