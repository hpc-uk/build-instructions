Instructions for compiling NAMD 2.12 for Cirrus
====================================================

These instructions are for compiling NAMD 2.12 on Cirrus (SGI ICE XA, Broadwell) using the GCC 6 compilers and Intel MPI 17.

Download and unpack NAMD
------------------------

First download the NAMD source from: http://www.ks.uiuc.edu/Development/Download/download.cgi?PackageName=NAMD
and transfer to the Cirrus system.

Unpack the source

```bash
tar -xvf NAMD_2.12_Source.tar.gz
```

Setup modified TCL
------------------

Download, unpack and link:

```bash
cd NAMD_2.12_Source
wget http://www.ks.uiuc.edu/Research/namd/libraries/tcl8.5.9-linux-x86_64.tar.gz
wget http://www.ks.uiuc.edu/Research/namd/libraries/tcl8.5.9-linux-x86_64-threaded.tar.gz
tar xzf tcl8.5.9-linux-x86_64.tar.gz
tar xzf tcl8.5.9-linux-x86_64-threaded.tar.gz
mv tcl8.5.9-linux-x86_64 tcl
mv tcl8.5.9-linux-x86_64-threaded tcl-threaded
```

Setup correct modules
---------------------

```bash
module load gcc/6.2.0
module load intel-mpi-17
module load fftw-3.3.5-gcc-6.2.0-6tqf43m
```

Extract and Build Charm++
--------------------------

```bash
tar -xvf charm-6.7.1.tar
cd charm-6.7.1
export MPICXX=mpicxx
./build charm++ mpi-linux-x86_64 -j4 --with-production
cd ..
```

Build NAMD
----------

```bash
./config Linux-x86_64-g++ --with-fftw --with-fftw3 --charm-arch mpi-linux-x86_64
cd Linux-x86_64-g++/
gmake -j4
```

This will create the executable `namd2` in the Linux-x86_64-g++/ directory.

