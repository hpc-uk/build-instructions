# Introduction

This document provides instructions on how to build CP2K 7.1 and its
dependencies on ARCHER.

Further information on CP2K can be found at
[the CP2Kwebsite](https://www.cp2k.org) and on the ARCHER
[CP2K documentation page](http://www.archer.ac.uk/documentation/software/cp2k/).

The official build instructions for CP2K are at
https://www.cp2k.org/howto:compile which recommends that the easiest
way to install prerequisites is via te toolchain script.

For historical reasons, the ARCHER build instructions will use the "manual"
route which builds each relevant prerequisite independently.

FURTHER DETAILS ON THE TOOLCHAIN ROUTE PENDING

## General

* We will use the GNU programming environment
* We will target the sopt, psmp, and popt builds for CP2K and so
  it is useful to build some of the prerequisites both with an without
  OpenMP.
* Note that if the autotuned version of libgrid is required, this can
  take some time to runm so you might want to do this first. See the
  LIBGRID SECTION.



## Dependencies

Following https://www.cp2k.org/howto:compile we have the following
depencencies

CP2K | Name         | Optional | Build?    | Comment
---- | ----         | -------- | ------    | -------
2a.  | Gnu make     | No       | Available |
2b.  | Python       | No       | Available | `module load anaconda/python2`
2c.  | Fortran/C/C++| No       | Available | via module `gcc/6.3.0`
2d.  | BLAS/LAPACK  | No       | Available | via module `cray-libsci/16.11.1`
2e.  | MPI?SCLAPACK | Yes      | Available | 
2f.  | FFTW         | Yes      | Avaialble | `module load fftw/3.3.6.1`
2g.  | libint       | Yes      | Build     | 
2h.  | libsmm       | Yes      | No        | Using libxsmm
2i.  | libxsmm      | Yes      | Build     |
2j.  | CUDA         | Yes      | --        | Not relevant
2k.  | libxc        | Yes      | Build     |
2l.  | ELPA         | Yes      | Build     |
2m.  | PEXSI        | Yes      | No        | Why not?
2n.  | QUIP         | Yes      | No        | Why not?
2o.  | PLUMED       | Yes      | Build     |
2p.  | spglib       | Yes      | No        | Why not?
2q.  | SIRIUS       | Yes      | No        | Holly is trying this
2r.  | FPGA         | Yes      | --        | Not relevant


# Preliminaries

## Set GNU programming environment

First of all, we need to switch to the GNU compiler suite:

```
$ module swap PrgEnv-cray PrgEnv-gnu
```
which is relevant to all of waht follows. In an attempt to make clear
which modules are relevant for which parts of the build, the relevant
module commands are repeated in each section. They don't need to be
repeated in practice.

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
$ module swap PrgEnv-cray PrgEnv-gnu
$ module load gcc/6.3.0
$ module load anaconda/python2

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
$ wget https://github.com/hfp/libxsmm/archive/1.13.tar.gz
$ tar zxvf 1.13.tar.gz
$ cd libxsmm-1.13
```

Compile and install in one go
```
$ module swap PrgEnv-cray PrgEnv-gnu
$  make CC=cc CXX=CC FC=ftn INTRINSICS=1 PREFIX=${CP2K_ROOT}/libs/libxsmm install
```

If the `libxsmm` tests are required, avoid generating a `-lblas` at link stage via
```
$ make CC=cc CXX=CC FC-ftn INTRINSICS=1 BLAS=0 tests
```

### Notes

* At the time of writing, the latest version 1.14 does not compile on ARCHER under gcc/6.3.0
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
$ module swap PrgEnv-cray PrgEnv-gnu
$ CC=cc CXX=CC FC=ftn ./configure --prefix=${CP2K_ROOT}/libs/libxc
$ make
$ make check
$ make install
```

## ELPA

From https://elpa.mpcdf.mpg.de/software download e.g.,

```
$ wget http://elpa.mpcdf.mpg.de/html/Releases/2019.11.001/elpa-2019.11.001.tar.gz
$ tar zxvf elpa-2019.11.001.tar.gz
$ cd elpa-2019.11.001
```

ELPA install instructions are at https://gitlab.mpcdf.mpg.de/elpa/elpa/blob/master/INSTALL.md

We need separate builds for serial and OpenMP implementations; these can be managed
by making separate build sub-directories.

```
$ module swap PrgEnv-cray PrgEnv-gnu
```

### Serial

```
$ mkdir build-serial
$ cd build-serial
$ CC=cc CXX=CC FC=ftn LDFLAGS=-dynamic ../configure      \
  --enable-openmp=no --enable-shared=no \
  --disable-avx2 --disable-avx512       \
  --prefix=${CP2K_ROOT}/libs/elpa
$ make
$ make install
```

### OpenMP

Just set the OpenMP configure switch
```
$ mkdir build-openmp
$ cd build-openmp
$ CC=cc CXX=CC FC=ftn LDFLAGS=-dynamic ../configure       \
  --enable-openmp=yes --enable-shared=no \
  --disable-avx2 --disable-avx512        \
  --prefix=${CP2K_ROOT}/libs/elpa
$ make
$ make install
```

#### Notes

* Note that the prefix location is the same in each case.
* The `--disable-avx2` and `--disable-avx512` prevent compilation failure.
* The install stage wants to link a dynamic object hence `LDFLAGS=-dynamic`
* Don't try the tests until figure out where the request for a password is coming from.


## Plumed

From  https://github.com/plumed/plumed2 download, e.g.,

```
$ wget https://github.com/plumed/plumed2/releases/download/v2.6.0/plumed-2.6.0.tgz
$ tar zxvf plumed-2.6.0.tgz
$ cd plumed-2.6.0.tgz
```

Compile
```
$ CC=cc CXX=CC FC=ftn MPIEXEC=aprun ./configure      \
  --disable-openmp --disable-shared --disable-dlopen \
  --prefix=${CP2K_ROOT}/libs/plumed
$ make
$ make install
```

### Notes

* The `--disable-openmp` is for the serial build
* The `--disable-shared --disable-dlopen` avoid SEGV at CP2K run time in
  the plumed initialisation. This is caused by a call to `dlopen()`.
* One can also avoid this problem at run time by setting the environment
  variable `PLUMED_LOAD_SKIP_REGISTRATION`, but we choose to avoid it completely.




# Compile CP2K itself

General

* `-ffast-math` is not supported and will fail in main compilation
  with a message saying this may cause errors/instability.
* Remove `-g` from final version to remove about 100MB from the executable

## libgrid autotuning

Currently problematic

## CP2K sopt

The arch file is `$CP2K_ROOT/arch/ARCHER.sopt`: JUST CHECK IN THE FILE!?

```
CC       = cc
FC       = ftn
LD       = ftn 
AR       = ar -r

CP2K_ROOT  = /work/z01/z01/kevin/cp2k/cp2k-7.1

# Provides PLUMED_DEPENDENCIES

include $(CP2K_ROOT)/libs/plumed/lib/plumed/src/lib/Plumed.inc.static

# Options

DFLAGS   = -D__FFTW3 -D__LIBXC -D__LIBXSMM  -D__PLUMED2 \
           -D__ELPA=201911 -D__LIBINT -D__MAX_CONTR=4   \
           -D__STATM_RESIDENT

CFLAGS   = -O3 -funroll-loops -ftree-vectorize -mavx \
           -ffree-form -ffree-line-length-512

FCFLAGS  = $(DFLAGS) $(CFLAGS) \
           -I$(CP2K_ROOT)/libs/libint/include  \
           -I$(CP2K_ROOT)/libs/libxsmm/include \
           -I$(CP2K_ROOT)/libs/libxc/include   \
           -I$(CP2K_ROOT)/libs/elpa/include/elpa-2019.11.001/modules \
           -I$(CP2K_ROOT)/libs/elpa/include/elpa-2019.11.001/elpa

LDFLAGS  = $(FCFLAGS)

LIBS     = -L$(CP2K_ROOT)/libs/libint/lib -lint2  \
           -L$(CP2K_ROOT)/libs/libxsmm/lib -lxsmmf -lxsmm -lxsmmext \
           -L$(CP2K_ROOT)/libs/libxc/lib -lxcf90 -lxcf03 -lxc \
           -L$(CP2K_ROOT)/libs/elpa/lib -lelpa \
           $(PLUMED_DEPENDENCIES) -lfftw3 -lz -ldl -lstdc++
```

And compile

```
$ cd ${CP2K_ROOT}
$ make ARCH=ARCHER VERSION=sopt
```

### Regression tests

We require a test configuration file based `${CP2K_ROOT}/arch/ARCHER-regtest.sopt.conf`

```
# Name of the Fortran compiler used
export FORT_C_NAME=gnu

# Base directory of CP2K
dir_base=$PWD

# CP2K version: sopt (serial), popt (MPI), ssmp (OpenMP), psmp (MPI+OpenMP) or o
ther (debug...)
cp2k_version=sopt

# Do not rebuild should be the default
quick="quick"
nobuild="nobuild"

# Arch 
# dir_triplet=ARCHER-${FORT_C_NAME}
dir_triplet=ARCHER
export ARCH=ARCHER

# CP2K directory in the base directory
cp2k_dir=

# Number of MPI processes per task: should be 1 for serial or 2 for parallel run
s
numprocs=1

# Number of threads per process: should be 2 or more for OpenMP runs otherwise 1
numthreads=1

# Maximum number of tasks (CPU cores assigned) for compilation and execution
# Set maxtasks greater than numprocs*numthreads or to a multiple of it
# Allocate all CPU cores for the regtest run

maxtasks=24

# Turn YES if a memory leak checker is used
leakcheck="NO"

# Default error tolerance
default_err_tolerance="1.0E-14"

# *** how to execute an input file [ cp2k_prefix input cp2k_postfix ]
# Leave empty for serial, add path to mpirun for parallel execution
cp2k_run_prefix="aprun -n ${numprocs}"

# Allow the config file to set the maximum allowed time. Useful for valgrind runs
job_max_time="600"
```

This can be exectuted in the queue system via a script in `${CP2K_ROOT}`

```
#!/bin/bash --login

#PBS -l select=1
#PBS -l walltime=00:20:00
#PBS -A z19-cse

export PBS_O_WORKDIR=$(readlink -f $PBS_O_WORKDIR)               

cd $PBS_O_WORKDIR

export OMP_NUM_THREADS=1

./tools/regtesting/do_regtest -nobuild -c arch/ARCHER-regtest.sopt.conf
```

## CP2K psmp

We require an arch file `${CP2K_ROOT}/arch/ARCHER.psmp`

```
# CP2K arch file for ARCHER psmp

CC       = cc
FC       = ftn -fopenmp
LD       = ftn -fopenmp
AR       = ar -r

CP2K_ROOT  = /work/z01/z01/kevin/cp2k/cp2k-7.1

# Provides PLUMED_DEPENDENCIES

include $(CP2K_ROOT)/libs/plumed/lib/plumed/src/lib/Plumed.inc.static

# Options

DFLAGS   = -D__FFTW3 -D__LIBXC -D__LIBXSMM  -D__PLUMED2 \
           -D__ELPA=201911 -D__LIBINT -D__MAX_CONTR=4   \
           -D__parallel -D__SCALAPACK -D__MPI_VERSION=3 \
           -D__STATM_RESIDENT
CFLAGS   = -O3 -funroll-loops -ftree-vectorize -mavx \
           -ffree-form -ffree-line-length-512

FCFLAGS  = $(DFLAGS) $(CFLAGS) \
           -I$(CP2K_ROOT)/libs/libint/include  \
           -I$(CP2K_ROOT)/libs/libxsmm/include \
           -I$(CP2K_ROOT)/libs/libxc/include   \
           -I$(CP2K_ROOT)/libs/elpa/include/elpa_openmp-2019.11.001/modules \
           -I$(CP2K_ROOT)/libs/elpa/include/elpa_openmp-2019.11.001/elpa

LDFLAGS  = $(FCFLAGS)

LIBS     = -L$(CP2K_ROOT)/libs/libint/lib -lint2  \
           -L$(CP2K_ROOT)/libs/libxsmm/lib -lxsmmf -lxsmm -lxsmmext \
           -L$(CP2K_ROOT)/libs/libxc/lib -lxcf90 -lxcf03 -lxc \
           -L$(CP2K_ROOT)/libs/elpa/lib -lelpa_openmp \
           $(PLUMED_DEPENDENCIES) -lfftw3 -lfftw3_threads -lz -ldl -lstdc++
```

And compile

```
$ cd ${CP2K_ROOT}
$ make ARCH=ARCHER VERSION=psmp
```

### Regression tests

The test config file is `${CP2K_ROOT}/arch/ARCHER-regtest.psmp.conf`

```
# Name of the Fortran compiler used
export FORT_C_NAME=gnu

# Base directory of CP2K
dir_base=$PWD

# CP2K version: sopt (serial), popt (MPI), ssmp (OpenMP), psmp (MPI+OpenMP) or o
ther (debug...)
cp2k_version=psmp

# Do not rebuild should be the default
quick="quick"
nobuild="nobuild"

# Arch 
# dir_triplet=ARCHER-${FORT_C_NAME}
dir_triplet=ARCHER
export ARCH=ARCHER

# CP2K directory in the base directory
cp2k_dir=

# Number of MPI processes per task: should be 1 for serial or 2 for parallel run
s
numprocs=2

# Number of threads per process: should be 2 or more for OpenMP runs otherwise 1
numthreads=2
export OMP_STACKSIZE=65000

# Maximum number of tasks (CPU cores assigned) for compilation and execution
# Set maxtasks greater than numprocs*numthreads or to a multiple of it
# Allocate all CPU cores for the regtest run

maxtasks=24

# Turn YES if a memory leak checker is used
leakcheck="NO"

# Default error tolerance
default_err_tolerance="1.0E-14"

# *** how to execute an input file [ cp2k_prefix input cp2k_postfix ]
# Leave empty for serial, add path to mpirun for parallel execution
cp2k_run_prefix="aprun -n ${numprocs} -S ${numprocs} -d ${numthreads}"

# Allow the config file to set the maximum allowed time. Useful for valgrind run
s
job_max_time="600"
```

And run from `${CP2K_ROOT}` via a PBS script

```
#!/bin/bash --login

#PBS -l select=1
#PBS -l walltime=12:00:00
#PBS -A z19-cse

export PBS_O_WORKDIR=$(readlink -f $PBS_O_WORKDIR)               

cd $PBS_O_WORKDIR

export OMP_NUM_THREADS=2

./tools/regtesting/do_regtest -nobuild -c arch/ARCHER-regtest.psmp.conf
```



## CP2K popt



### Regression tests




## Regression tests
`
