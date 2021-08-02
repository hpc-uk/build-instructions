# Introduction

This document provides instructions on how to build CP2K 8.1 and its
dependencies on [HLRS Hawk](https://www.hlrs.de/systems/hpe-apollo-hawk/).

Further information on CP2K can be found at
[the CP2Kwebsite](https://www.cp2k.org) and on the ARCHER
[CP2K documentation page](http://www.archer.ac.uk/documentation/software/cp2k/).

The official build instructions for CP2K are at
https://www.cp2k.org/howto:compile which recommends that the easiest
way to install prerequisites is via te toolchain script.

For historical reasons, the Hawk build instructions will use the "manual"
route which builds each relevant prerequisite independently.

## General

* We will use the GNU programming environment.
* We will only consider the psmp builds for CP2K.
* The autotuned version of libgrid was not built.

## Dependencies

Following https://www.cp2k.org/howto:compile we have the following
depencencies

CP2K | Name         | Optional | Build?    | Comment
---- | ----         | -------- | ------    | -------
2a.  | Gnu make     | No       | Available |
2b.  | Python       | No       | Available | 
2c.  | Fortran/C/C++| No       | Available | via module `gcc/9.2.0`
2d.  | BLAS/LAPACK  | No       | Available | via module `mkl`
2e.  | MPI?SCLAPACK | Yes      | Available | via module `scalapack/2.1.0-shared-MKLshared`
2f.  | FFTW         | Yes      | Avaialble | via moduel `fftw`
2g.  | libint       | Yes      | Build     | 
2h.  | libsmm       | Yes      | No        | Using libxsmm
2i.  | libxsmm      | Yes      | Build     |
2j.  | CUDA         | Yes      | --        | Not relevant
2k.  | libxc        | Yes      | Build     |
2l.  | ELPA         | Yes      | Build     |
2m.  | PEXSI        | Yes      | No        | Not required
2n.  | QUIP         | Yes      | No        | Not required
2o.  | PLUMED       | Yes      | No        | Not required
2p.  | spglib       | Yes      | No        | Not required
2q.  | SIRIUS       | Yes      | No        | Not required
2r.  | FPGA         | Yes      | --        | Not relevant


# Preliminaries

## Set GNU programming environment

First of all, we need to setup the build environment. The `gcc/9.2.0` and
`mpt/2.23` modules are loaded by default so we add the additional modules
with:

```
$ module load mkl
$ module load scalapack/2.1.0-shared-MKLshared
$ module load fftw
```

In an attempt to make clear
which modules are relevant for which parts of the build, the relevant
module commands are repeated in each section. They don't need to be
repeated in practice.


### Set `CP2K_ROOT`

From the CP2K web site, download the appropriate release of the code: 

```
$ wget https://github.com/cp2k/cp2k/releases/download/v8.1.0/cp2k-8.1.tar.bz2
```
Note: here we get the `.bz2` bundle as it contains the DBCSR submodule
(the `.tar.gz` does not for some reason).

 Untar this into a location on the `/work` file system:
 ```
 $ bunzip2 cp2k-8.1.tar.bz2
 $ tar xvf cp2k-8.1.tar
 $ cd cp2k-8.1
 $ ls
 COPYRIGHT   LICENSE   README.md  arch        data  src    tools
 INSTALL.md  Makefile  REVISION   benchmarks  exts  tests
 $ export CP2K_ROOT=$PWD
```
Note we have set the environment variable `CP2K_ROOT` to be the top-level
CP2K directory. We will refer to this in what follows.

# Compile, hope, and be thankful

The following may be downloaded to a location of choice, but they will all be installed
in `${CP2K_ROOT}/libs`.

## libint

CP2K releases versions of `libint` appropirate for CP2K at https://github.com/cp2k/libint-cp2k
so a download can be selected. A choice is required on the highest `lmax` supported: we choose
`lmax = 4`.

```
$ wget https://github.com/cp2k/libint-cp2k/releases/download/v2.6.0/libint-v2.6.0-cp2k-lmax-4.tgz
$ tar zxvf libint-v2.6.0-cp2k-lmax-4.tgz
$ cd libint-v2.6.0-cp2k-lmax-4
```

The `libint` web site suggests that `cmake` should be the standard build approach,
but here we use standard `make`.

```
$ CC=gcc CXX=g++ FC=gfortran LIBS=-lstdc++ \
           ./configure --enable-fortran --with-cxx-optflags=-O --enable-shared \
            --prefix=${CP2K_ROOT}/libs/libint
$ make
$ make check
$ make install
```

## libxsmm

From https://github.com/hfp/libxsmm/ download version 1.16.1

```
$ wget https://github.com/hfp/libxsmm/archive/1.16.1.tar.gz
$ tar zxvf 1.16.1.tar.gz
$ cd libxsmm-1.16.1
```

Compile and install in one go

```
$  make CC=gcc CXX=g++ FC=gfortran INTRINSICS=1 PREFIX=${CP2K_ROOT}/libs/libxsmm install
```

If the `libxsmm` tests are required, avoid generating a `-lblas` at link stage via
```
$ make CC=gcc CXX=g++ FC=gfortran INTRINSICS=1 BLAS=0 tests
```

### Notes

* It is recommended to do the "compile and install in one go" approach, as
  separate stages of make are somewhat opaque in libxsmm.

## libxc

From https://www.tddft.org/programs/libxc/ download a version, e.g.,

```
$ wget -O libxc-4.3.4.tar.gz https://www.tddft.org/programs/libxc/down.php?file=4.3.4/libxc-4.3.4.tar.gz
$ tar zxvf libxc-4.3.4.tar.gz
$ cd libxc-4.3.4
```

Compilation and tests may be treated conveniently

```
$ CC=gcc CXX=g++ FC=gfortran ./configure --prefix=${CP2K_ROOT}/libs/libxc
$ make
$ make check
$ make install
```

## ELPA

From https://elpa.mpcdf.mpg.de/software download e.g.,

```
$ wget https://elpa.mpcdf.mpg.de/html/Releases/2020.05.001/elpa-2021.05.002.tar.gz
$ tar xvf elpa-2021.05.002.tar.gz
$ cd elpa-2021.05.002
```

ELPA install instructions are at https://gitlab.mpcdf.mpg.de/elpa/elpa/blob/master/INSTALL.md

```
$ module load mkl
$ module load scalapack/2.1.0-shared-MKLshared
$ mkdir build-openmp
$ cd build-openmp
$ export CC=mpicc
$ export CXX=mpicxx
$ export FC=mpif90
$ export LIBS='-lscalapack -L${MKLROOT}/lib/intel64 -lmkl_scalapack_lp64 -Wl,--no
-as-needed -lmkl_gf_lp64 -lmkl_gnu_thread -lmkl_core -lmkl_blacs_sgimpt_lp64 -lgomp -lpthread -lm -ldl'
$ ../configure --enable-openmp=yes --enable-shared=yes \
  --disable-avx512 --prefix=${CP2K_ROOT}/libs/elpa-openmp
$ make
$ make install
```

#### Notes

* Note that the prefix location is the same in each case.
* The  `--disable-avx512` prevent compilation failure.

# Compile CP2K itself

General

* `-ffast-math` is not supported and will fail in main compilation
  with a message saying this may cause errors/instability.
* One can remove `-g` from final version to remove about 100MB from the
  executable, but it may be desirable to retain it to provide some
  information in the case of failures.

```
$ module load mkl
$ module load scalapack/2.1.0-shared-MKLshared
$ module load fftw
```


## CP2K psmp

The arch file is [./hawk.psmp](./hawk.psmp). Place this file in the
`$CP2K_ROOT/arch` directory and then edit CP2K_ROOT and
DATA_DIR to point to the correct locations.

Compile with:

```
$ cd ${CP2K_ROOT}
$ make ARCH=hawk VERSION=psmp
```


