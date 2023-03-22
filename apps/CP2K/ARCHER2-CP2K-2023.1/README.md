# Introduction

This document provides instructions on how to build CP2K 2023.1 and its dependencies on ARCHER2 full system.

Further information on CP2K can be found at [the CP2K website](https://www.cp2k.org) and on the
[ARCHER2 CP2K documentation page](https://docs.archer2.ac.uk/research-software/cp2k/).

The official build instructions for CP2K are at [https://github.com/cp2k/cp2k/blob/master/INSTALL.md](https://github.com/cp2k/cp2k/blob/master/INSTALL.md).
The ARCHER2 build instructions however use the "manual" route, building each relevant prerequisite independently.

## General

* We will use the GNU programming environment.
* We will only consider psmp build for CP2K.
* The autotuned version of libgrid was not built as there were some
  residual problems with the automatic code generation on ARCHER2.


# Preliminaries

## Prepare module environment

```
module load PrgEnv-gnu
module load cpe/21.09
module load mkl
module load cray-fftw
export LD_LIBRARY_PATH=${CRAY_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}
export FCFLAGS="-fallow-argument-mismatch"
```

The above commands load the Cray Programming Environment (CPE) 21.09 and the GNU compiler suite.
Then, the Intel Maths Kernel Library (MKL) module is loaded, replacing the `cray-libsci` module.


## Prepare CP2K build environment

```
PRFX=/path/to/work/dir # e.g., /work/y07/shared/apps/core 
CP2K_LABEL=cp2k
CP2K_VERSION=2023.1
CP2K_NAME=${CP2K_LABEL}-${CP2K_VERSION}
CP2K_BASE=${PRFX}/${CP2K_LABEL}
CP2K_ROOT=${CP2K_BASE}/${CP2K_NAME}

mkdir -p ${CP2K_BASE}
cd ${CP2K_BASE}

rm -rf ${CP2K_NAME}
wget -q https://github.com/${CP2K_LABEL}/${CP2K_LABEL}/releases/download/v${CP2K_VERSION}/${CP2K_NAME}.tar.bz2
bunzip2 ${CP2K_NAME}.tar.bz2
tar xf ${CP2K_NAME}.tar
rm ${CP2K_NAME}.tar
```


## Build libint

CP2K releases versions of `libint` appropriate for CP2K at https://github.com/cp2k/libint-cp2k .
A choice is required on the highest `lmax` supported: we choose `lmax = 4` to limit the size of the static executable.

```
cd ${CP2K_ROOT}/libs

LIBINT_LABEL=libint
LIBINT_VERSION=2.6.0
LIBINT_SUFFIX=cp2k-lmax-4
LIBINT_NAME=${LIBINT_LABEL}-v${LIBINT_VERSION}-${LIBINT_SUFFIX}

rm -rf ${LIBINT_NAME}
wget -q https://github.com/${CP2K_LABEL}/${LIBINT_LABEL}-${CP2K_LABEL}/releases/download/v${LIBINT_VERSION}/${LIBINT_NAME}.tgz
tar zxf ${LIBINT_NAME}.tgz
rm ${LIBINT_NAME}.tgz
cd ${LIBINT_NAME}

CC=cc CXX=CC FC=ftn LDFLAGS=-dynamic ./configure \
    --enable-fortran --with-cxx-optflags=-O \
    --prefix=${CP2K_ROOT}/libs/libint
make
make install
```


## Build libxc

```
cd ${CP2K_ROOT}/libs

LIBXC_LABEL=libxc
LIBXC_VERSION=6.1.0
LIBXC_NAME=${LIBXC_LABEL}-${LIBXC_VERSION}

rm -rf ${LIBXC_NAME}
wget -q -O ${LIBXC_NAME}.tar.gz https://www.tddft.org/programs/${LIBXC_LABEL}/down.php?file=${LIBXC_VERSION}/${LIBXC_NAME}.tar.gz
tar zxf ${LIBXC_NAME}.tar.gz
rm ${LIBXC_NAME}.tar.gz
cd ${LIBXC_NAME}

CC=cc CXX=CC FC=ftn ./configure --prefix=${CP2K_ROOT}/libs/libxc
make
make install
```


## Build libxsmm

```
cd ${CP2K_ROOT}/libs

LIBXSMM_LABEL=libxsmm
LIBXSMM_VERSION=1.17
LIBXSMM_NAME=${LIBXSMM_LABEL}-${LIBXSMM_VERSION}

rm -rf ${LIBXSMM_NAME}
wget -q https://github.com/hfp/${LIBXSMM_LABEL}/archive/${LIBXSMM_VERSION}.tar.gz
tar zxf ${LIBXSMM_VERSION}.tar.gz
rm ${LIBXSMM_VERSION}.tar.gz
cd ${LIBXSMM_NAME}

make CC=cc CXX=CC FC=ftn INTRINSICS=1 PREFIX=${CP2K_ROOT}/libs/libxsmm install
```


## Build ELPA

```
cd ${CP2K_ROOT}/libs

ELPA_LABEL=elpa
ELPA_VERSION=2022.11.001
ELPA_NAME=${ELPA_LABEL}-${ELPA_VERSION}

rm -rf ${ELPA_NAME}
wget -q https://elpa.mpcdf.mpg.de/software/tarball-archive/Releases/${ELPA_VERSION}/${ELPA_NAME}.tar.gz
tar zxf ${ELPA_NAME}.tar.gz
rm ${ELPA_NAME}.tar.gz

cd ${ELPA_NAME}
mkdir build-serial
cd build-serial
export LIBS="-L${MKLROOT}/lib/intel64 -lmkl_scalapack_lp64 -Wl,--no-as-needed -lmkl_gf_lp64 -lmkl_gnu_thread -lmkl_core -lmkl_blacs_intelmpi_lp64 -lgomp -lpthread -lm -ldl"
CC=cc CXX=CC FC=ftn LDFLAGS=-dynamic ../configure       \
  --enable-openmp=no --enable-shared=no \
  --disable-avx512 --disable-detect-mpi-launcher \
  --without-threading-support-check-during-build \
  --prefix=${CP2K_ROOT}/libs/elpa-serial
make
make install

cd ${CP2K_ROOT}/libs/${ELPA_NAME}
mkdir build-openmp
cd build-openmp
export LIBS="-L${MKLROOT}/lib/intel64 -lmkl_scalapack_lp64 -Wl,--no-as-needed -lmkl_gf_lp64 -lmkl_gnu_thread -lmkl_core -lmkl_blacs_intelmpi_lp64 -lgomp -lpthread -lm -ldl"
CC=cc CXX=CC FC=ftn LDFLAGS=-dynamic ../configure \
  --enable-openmp=yes --enable-shared=no --enable-allow-thread-limiting \
  --disable-avx512 --disable-detect-mpi-launcher \
  --without-threading-support-check-during-build \
  --prefix=${CP2K_ROOT}/libs/elpa-openmp
make
make install
```


## Build Plumed

```
cd ${CP2K_ROOT}/libs

PLUMED_LABEL=plumed
PLUMED_VERSION=2.8.1
PLUMED_NAME=${PLUMED_LABEL}-${PLUMED_VERSION}

rm -rf ${PLUMED_NAME}
wget -q https://github.com/${PLUMED_LABEL}/${PLUMED_LABEL}2/releases/download/v${PLUMED_VERSION}/${PLUMED_NAME}.tgz
tar zxf ${PLUMED_NAME}.tgz
rm ${PLUMED_NAME}.tgz
cd ${PLUMED_NAME}

CC=cc CXX=CC FC=ftn MPIEXEC=srun ./configure \
  --disable-openmp --disable-shared --disable-dlopen \
  --prefix=${CP2K_ROOT}/libs/plumed
make
make install
```


## Build CP2K

Download the `ARCHER2.psmp` file from [https://github.com/hpc-uk/build-instructions/tree/main/apps/CP2K/ARCHER2-CP2K-2023.1](https://github.com/hpc-uk/build-instructions/tree/main/apps/CP2K/ARCHER2-CP2K-2023.1)
and copy to `/work/y07/shared/apps/core/${CP2K_LABEL}/${CP2K_NAME}/arch/`.

```
cd ${CP2K_ROOT}

sed -i "s:CP2K_ROOT = .*/${CP2K_NAME}:CP2K_ROOT = ${CP2K_ROOT}:" ${CP2K_ROOT}/arch/ARCHER2.psmp

make ARCH=ARCHER2 VERSION=psmp
make clean ARCH=ARCHER2 VERSION=psmp
```


### Regression tests

Download the `ARCHER2-regtest.psmp.conf` configuration file from [https://github.com/hpc-uk/build-instructions/tree/main/apps/CP2K/ARCHER2-CP2K-2023.1](https://github.com/hpc-uk/build-instructions/tree/main/apps/CP2K/ARCHER2-CP2K-2023.1)
and copy to `${CP2K_ROOT}`.

The test can be executed in the queue system by submitting script from `${CP2K_ROOT}`.

```
#!/bin/bash

#SBATCH --job-name=regtest
#SBATCH --time=02:00:00
#SBATCH --exclusive
#SBATCH --partition=standard
#SBATCH --qos=standard
#SBATCH --account=<budget code>
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --tasks-per-node=2
#SBATCH --cpus-per-task=2

module load PrgEnv-gnu
module load cpe/21.09
module load mkl

export LD_LIBRARY_PATH=${CRAY_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}

export OMP_NUM_THREADS=2

./tools/regtesting/do_regtest -nobuild -c ./ARCHER2-regtest.psmp.conf
```

The regression tests should take around 2 hrs 40 mins to complete (assuming CPU frequency of 2.0 GHz)
and the summarized results should be as shown below.

```
--------------------------------- Summary --------------------------------
Number of FAILED  tests 0
Number of WRONG   tests 0
Number of CORRECT tests 3664
Total number of   tests 3664
GREPME 0 0 3664 0 3664 X

Summary: correct: 3664 / 3664; 160min
Status: OK
```
