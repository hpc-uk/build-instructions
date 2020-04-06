# Introduction

These instructions are for building CP2K version 7.1 on Cirrus.

A number of different compilers are available on Cirrus, so following
the list at  https://www.cp2k.org/dev:compiler_support
I select

```
$ module load intel-mpi-18 intel-compilers-18 intel-cmkl-18/18.0.5.274
```
being the modules for Intel MPI, Intel compilers, and the math kernel
library MKL.

In particular, at the time of writing, we do not have a version
of Intel 19 which shows a positive result in the above list.



Dependencies



** libint

$ wget https://github.com/cp2k/libint-cp2k/releases/download/v2.6.0/libint-v2.6.0-cp2k-lmax-4.tgz
$ tar zxvf libint-v2.6.0-cp2k-lmax-4.tgz
$ cd libint-v2.6.0-cp2k-lmax-4

$ CC=icc CXX=icpc FC=ifort ./configure \
                           --enable-fortran --with-cxx-optflags=-O \
                           --prefix=${CP2K_ROOT}/libs/libint

$ make
$ make check
$ make install

Notes
* At the install stage the link of a Fortran example may fail with "undefined
reference to main". The link should be carried out with `ifort`, not `icpc`.



