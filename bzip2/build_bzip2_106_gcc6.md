Instructions for compiling bzip2 1.* with GCC Compilers 
=======================================================

These instructions are known to work successfully for bzip2 1.0.6 with
Intel Compilers 2016 on [Cirrus](http://www.epcc.ed.ac.uk/cirrus) (a
SGI ICE XA system).

Download and unpack bzip2
-------------------------

```bash
wget ...
tar -xvf bzip2-1.0.6.tar.gz
```

Create install directory and setup environment
----------------------------------------------

Move to the source directory and create an install directory:

```bash
cd bzip2-1.0.6
mkdir ../bzip2
```

Load the MPT (MPI) module and the Intel compiler module. Also 
need to set environment variables to pick up the correct compilers:

```bash
module load gcc
```

Build, Test, and Install
------------------------

```bash
make
make install PREFIX=/lustre/sw/bzip2/1.0.6-gcc6
```

