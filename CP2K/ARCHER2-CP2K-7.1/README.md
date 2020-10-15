# Introduction

This document provides instructions on how to build CP2K 7.1 and its
dependencies on ARCHER2.

Further information on CP2K can be found at
[the CP2Kwebsite](https://www.cp2k.org) and on the ARCHER
[CP2K documentation page](http://www.archer.ac.uk/documentation/software/cp2k/).

The official build instructions for CP2K are at
https://www.cp2k.org/howto:compile which recommends that the easiest
way to install prerequisites is via te toolchain script.

For historical reasons, the ARCHER build instructions will use the "manual"
route which builds each relevant prerequisite independently.

## General

* We will use the GNU programming environment
* We will only consider the popt and psmp builds for CP2K.
  It is useful to build some of the prerequisites both with an without
  OpenMP for popt.
* The autotuned version of libgrid was not built as there were some
  residual problems with the automatic code generation on Archer.



## Dependencies

Following https://www.cp2k.org/howto:compile we have the following
depencencies

CP2K | Name         | Optional | Build?    | Comment
---- | ----         | -------- | ------    | -------
2a.  | Gnu make     | No       | Available |
2b.  | Python       | No       | Available | `module load cray-python`
2c.  | Fortran/C/C++| No       | Available | via module `gcc/9.3.0`
2d.  | BLAS/LAPACK  | No       | Available | via module `cray-libsci`
2e.  | MPI?SCLAPACK | Yes      | Available | 
2f.  | FFTW         | Yes      | Avaialble | `module load cray-fftw`
2g.  | libint       | Yes      | Build     | 
2h.  | libsmm       | Yes      | No        | Using libxsmm
2i.  | libxsmm      | Yes      | Build     |
2j.  | CUDA         | Yes      | --        | Not relevant
2k.  | libxc        | Yes      | Build     |
2l.  | ELPA         | Yes      | Build     |
2m.  | PEXSI        | Yes      | No        | Not required
2n.  | QUIP         | Yes      | No        | Not required
2o.  | PLUMED       | Yes      | Build     |
2p.  | spglib       | Yes      | No        | Not required
2q.  | SIRIUS       | Yes      | No        | Not required
2r.  | FPGA         | Yes      | --        | Not relevant


# Preliminaries

## Set GNU programming environment

First of all, we need to switch to the GNU compiler suite:

```
$ module restore PrgEnv-gnu
```
which is relevant to all of waht follows. In an attempt to make clear
which modules are relevant for which parts of the build, the relevant
module commands are repeated in each section. They don't need to be
repeated in practice.

Note that at the time of writing the Gnu programming environment
supplies gcc/9.3.0 as the default.


### Set `CP2K_ROOT`

From the CP2K web site, download the appropriate release of the code: 

```
$ wget https://github.com/cp2k/cp2k/releases/download/v7.1.0/cp2k-7.1.tar.bz2
```
Note: here we get the `.bz2` bundle as it contains the DBCSR submodule
(the `.tar.gz` does not for some reason).

 Untar this into a location on the `/work` file system:
 ```
 $ bunzip2 cp2k-7.1.tar.bz2
 $ tar xvf cp2k-7.1.tar
 $ cd cp2k-7.1
 $ ls
 COPYRIGHT   LICENSE   README.md  arch        data  src    tools
 INSTALL.md  Makefile  REVISION   benchmarks  exts  tests
 $ export CP2K_ROOT=`pwd`
```
Note we have set the environment variable `CP2K_ROOT` to be the top-level
CP2K directory. We will refer to this in what follows.

# Compile, hope, and be thankful

The following may be downloaded to a location of choice, but they will all be installed
in `${CP2K_ROOT}/libs`.

## libint

CP2K releases versions of `libint` appropirate for CP2K at https://github.com/cp2k/libint-cp2k
so a download can be selected. A choice is required on the highest `lmax` supported: we choose
`lmax = 4` to limit the size of the static executable.

```
$ wget https://github.com/cp2k/libint-cp2k/releases/download/v2.6.0/libint-v2.6.0-cp2k-lmax-4.tgz
$ tar zxvf libint-v2.6.0-cp2k-lmax-4.tgz
$ cd libint-v2.6.0-cp2k-lmax-4
```

The `libint` web site suggests that `cmake` should be the standard build approach,
but here we use standard `make`.

```
$ module restore PrgEnv-gnu
$ module swap gcc gcc/9.3.0
$ module load cray-python

$ CC=cc CXX=CC FC=ftn LDFLAGS=-dynamic ./configure \
                                  --enable-fortran --with-cxx-optflags=-O \
                                  --prefix=${CP2K_ROOT}/libs/libint
$ make
$ make install
```

If you wish to run the `libint` tests, a dynamically linked test executable is required:

```
$ CC=cc CXX=CC FC=ftn LDFLAGS=-dynamic LIBS=-lstdc++ \
        ./configure --enable-fortran --with-cxx-optflags=-O --enable-shared \
                    --prefix=${CP2K_ROOT}/libs/libint
$ make
$ make check
$ make install
```

### Notes

* Anaconda python is required
* The `lmax=4` version gives a static archive of about 30 MB in size
* The `lmax=6` version gives a static archive of around 130 MB in size

## libxsmm

From https://github.com/hfp/libxsmm/ download version 1.13

```
$ wget https://github.com/hfp/libxsmm/archive/1.16.1.tar.gz
$ tar zxvf 1.16.1.tar.gz
$ cd libxsmm-1.16.1
```

Compile and install in one go
```
$ module restore PrgEnv-gnu
$ module swap gcc gcc/9.3.0
$  make CC=cc CXX=CC FC=ftn INTRINSICS=1 PREFIX=${CP2K_ROOT}/libs/libxsmm install
```

If the `libxsmm` tests are required, avoid generating a `-lblas` at link stage via
```
$ make CC=cc CXX=CC FC-ftn INTRINSICS=1 BLAS=0 tests
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
$ module restore PrgEnv-gnu
$ module swap gcc gcc/9.3.0
$ CC=cc CXX=CC FC=ftn ./configure --prefix=${CP2K_ROOT}/libs/libxc
$ make
$ make check
$ make install
```

## ELPA

From https://elpa.mpcdf.mpg.de/software download e.g.,

```
$ wget https://elpa.mpcdf.mpg.de/html/Releases/2020.05.001/elpa-2020.05.001.tar.gz
$ tar xvf elpa-2020.05.001.tar.gz
$ cd elpa-2020.05.001
```

ELPA install instructions are at https://gitlab.mpcdf.mpg.de/elpa/elpa/blob/master/INSTALL.md

We need separate builds for serial and OpenMP implementations; these can be managed
by making separate build sub-directories.

```
$ module restore PrgEnv-gnu
$ module swap gcc gcc/9.3.0
```

### OpenMP

Just set the OpenMP configure switch
```
$ mkdir build-openmp
$ cd build-openmp
$ CC=cc CXX=CC FC=ftn LDFLAGS=-dynamic ../configure       \
  --enable-openmp=yes --enable-shared=no \
  --disable-avx512        \
  --prefix=${CP2K_ROOT}/libs/elpa-openmp
$ make
$ make install
```

#### Notes

* Note that the prefix location is the same in each case.
* The  `--disable-avx512` prevent compilation failure.
* The install stage wants to link a dynamic object hence `LDFLAGS=-dynamic`
* Don't try the tests until figure out where the request for a password is coming from.


## Plumed

From  https://github.com/plumed/plumed2 download, e.g.,

```
$ wget https://github.com/plumed/plumed2/releases/download/v2.6.0/plumed-2.6.1.tgz
$ tar zxvf plumed-2.6.1.tgz
$ cd plumed-2.6.1.tgz
```

Compile
```
$ CC=cc CXX=CC FC=ftn MPIEXEC=srun ./configure      \
  --disable-openmp --disable-shared --disable-dlopen \
  --prefix=${CP2K_ROOT}/libs/plumed
$ make
$ make install
```

### Notes

* The `--disable-openmp` is for the serial build. We do not use an OpenMP
  as this has proved problematic elsewhere ([see ../CIRRUS-CP2k-7.1](../CIRRUS-CP2K-7.1))
  and there is no suggestion that it is required.
* The `--disable-shared --disable-dlopen` avoid SEGV at CP2K run time in
  the plumed initialisation. This is caused by a call to `dlopen()`.
* One can also avoid this problem at run time by setting the environment
  variable `PLUMED_LOAD_SKIP_REGISTRATION`, but we choose to avoid it
  completely via the configuration.




# Compile CP2K itself

General

* `-ffast-math` is not supported and will fail in main compilation
  with a message saying this may cause errors/instability.
* One can remove `-g` from final version to remove about 100MB from the
  executable, but it may be desirable to retain it to provide some
  information in the case of failures.

* CP2K requires a python to work out the dependencies, and a reminder
  we are in `PrgENV-gnu`

```
$ module load cray-python
$ module restore PrgEnv-gnu
$ module load cray-fftw
```


## libgrid autotuning

The build from the autotuning stage is currently problematic on ARCHER
apparently owing to various non-standard python packages required.


## CP2K psmp

The arch file is `$CP2K_ROOT/arch/ARCHER2.psmp` a copy of which is
supplied here [./ARCHER2.psmp](./ARCHER2.psmp)

And compile

```
$ cd ${CP2K_ROOT}
$ make ARCH=ARCHER2 VERSION=psmp
```

### Regression tests

We require a test configuration file based
`${CP2K_ROOT}/arch/ARCHER2-regtest.psmp.conf`
a copy of which we supply in the current directory as
[./ARCHER2-regtest.psmp.conf](./ARCHER2-regtest.psmp.conf)

This can be exectuted in the queue system via a script in `${CP2K_ROOT}`

```
#!/bin/bash

# Slurm job options (name, compute nodes, job time)
#SBATCH --job-name=regtest
#SBATCH --time=2:00:0
#SBATCH --exclusive
#SBATCH --nodes=1
#SBATCH --tasks-per-node=2
#SBATCH --cpus-per-task=2

# Replace [budget code] below with your budget code (e.g. t01)
#SBATCH --account=z19




export OMP_NUM_THREADS=2
export OMP_PLACES=cores

./tools/regtesting/do_regtest -nobuild -c arch/ARCHER2-regtest.psmp.conf
```
Notes

* Don't forget the `-nobuild`!

### Test results

