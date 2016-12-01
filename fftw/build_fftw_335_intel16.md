Instructions for compiling FFTW 3.* with Intel Compilers 
=========================================================

These instructions are known to work successfully for FFTW 3.3.5 with
Intel Compilers 2016 on [Cirrus](http://www.epcc.ed.ac.uk/cirrus) (a
SGI ICE XA system).

Download and unpack FFTW
------------------------

```bash
wget http://www.fftw.org/fftw-3.3.5.tar.gz
tar -xvf fftw-3.3.5.tar.gz
```

Create install directory and setup environment
----------------------------------------------

Move to the source directory and create an install directory:

```bash
cd fftw-3.3.5
mkdir ../fftw
```

Load the MPT (MPI) module and the Intel compiler module. Also 
need to set environment variables to pick up the correct compilers:

```bash
module load mpt
module intel-compilers-16
export CC=icc
export FC=ifort
export CXX=icpc
export MPICC='mpicc -cc=icc'
```

Configure the build
-------------------

Build with threaed and MPI-parallel versions enabled:

```bash
./configure --prefix=/lustre/home/z04/aturner/software/fftw/3.3.5-intel --enable-mpi --enable-threads --enable-openmp
```

Build, Test, and Install
------------------------

```bash
make -j 8
make check
make -j 8 install
```

