Instructions for building AOCL 3.1 for ARCHER2 with GCC-11
==========================================================

These instructions are for compiling the AOCL-3.1 libraries on ARCHER2 (HPE Cray EX, AMD Zen2 7742) using the GNU programming environment and GCC compiler.

Setup initial environment variables
-----------------------------------

```bash
PRFX=/path/to/install/location
AOCL_LABEL=aocl
AOCL_VERSION=3.1
AOCL_COMPILER=GNU
COMPILER_VERSION=11.2
AOCL_PRGENV=PrgEnv-gnu
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.

Setup installation and source directories
-----------------------------------------

``` bash
AOCL_SOURCE=${PRFX}/${AOCL_LABEL}/${AOCL_LABEL}-${AOCL_VERSION}
AOCL_MAKE=${PRFX}/${AOCL_LABEL}/${AOCL_VERSION}/${AOCL_COMPILER}/${COMPILER_VERSION}

mkdir -p ${AOCL_SOURCE}
mkdir -p ${AOCL_MAKE}
```

BLIS
=======

BLIS (BLAS Library) is a portable open-source software framework for performing high-performance Basic Linear Algebra Subprograms (BLAS) functionality.

Download the library source code
---------------------------------

```bash
cd ${AOCL_SOURCE}
git clone https://github.com/flame/blis.git
cd blis
```

Load modules
------------

```bash
module load ${AOCL_PRGENV}
module swap gcc/10.2.0 gcc/${COMPILER_VERSION}
```

```bash
eleanorb@ln01:~> module list

Currently Loaded Modules:
  1) craype/2.7.6                                8) bolt/0.7
  2) craype-x86-rome                             9) epcc-setup-env
  3) libfabric/1.11.0.4.71                      10) load-epcc-module
  4) craype-network-ofi                         11) PrgEnv-gnu/8.0.0
  5) perftools-base/21.02.0                     12) gcc/11.2.0
  6) xpmem/2.2.40-7.0.1.0_2.7__g1d7a24d.shasta  13) cray-mpich/8.1.4
  7) cray-libsci/21.04.1.1
```

Build multi-thread BLIS
-------------------------

```bash
./configure --enable-cblas --enable-threading=openmp --prefix=${AOCL_MAKE} auto

make
make install
```

Test:
```bash
BLIS_NUM_THREADS=1 make check
BLIS_NUM_THREADS=1 make test
BLIS_NUM_THREADS=2 make test
```


LibFLAME
=========

libFLAME (LAPACK) is a portable library for dense matrix computations that provides the
functionality present in the Linear Algebra Package (LAPACK).

Download the library source code
---------------------------------

```bash
cd ${AOCL_SOURCE}
git clone https://github.com/amd/libflame.git
cd libflame
```

Load modules
------------

```bash
module load ${AOCL_PRGENV}
module swap gcc/10.2.0 gcc/${COMPILER_VERSION}
module load cray-python
```

Build 32-bit Integer
---------------------

```bash
./configure --enable-blas-ext-gemmt --enable-lapack2flame --enable-external-lapackinterfaces --enable-dynamic-build --enable-max-arg-list-hack --prefix=${AOCL_MAKE}

make -j
make install
```

Test:
```bash
BLIS_NUM_THREADS=1 make check LIBBLAS="${AOCL_MAKE}/lib/libblis.a -fopenmp"
BLIS_NUM_THREADS=2 make check LIBBLAS="${AOCL_MAKE}/lib/libblis.a -fopenmp"
```

FFTW
=========

AMD-FFTW (Fastest Fourier Transform in the West) is a comprehensive collection of fast C
routines for computing the Discrete Fourier Transform (DFT) and various special cases.

Download the library source code
---------------------------------

```bash
cd ${AOCL_SOURCE}
git clone https://github.com/amd/amd-fftw.git
cd amd-fftw/
```

Load modules
------------

```bash
module load ${AOCL_PRGENV}
module swap gcc/10.2.0 gcc/${COMPILER_VERSION}
```

Build
--------
Note: ```make check``` tests the installation. All tests pass but there appears to be a syntax error in the script when building documentation. This error can be ignored.

Build single precision FFTW libraries:
```bash
MPICC=cc ./configure --enable-sse2 --enable-avx --enable-avx2 --enable-mpi --enable-openmp --enable-shared --enable-single --enable-amd-opt --enable-amd-mpifft --prefix=${AOCL_MAKE}

make
make install
make check
```

Build double precision FFTW libraries:
```bash
MPICC=cc ./configure --enable-sse2 --enable-avx --enable-avx2 --enable-mpi --enable-openmp --enable-shared --enable-amd-opt --enable-amd-mpifft --prefix=${AOCL_MAKE}

make
make install
make check
```


LibM
=======

LibM (AMD Core Math Library) is a software library containing a collection of basic math
functions optimized for x86-64 processor based machines.

Download the library source code
---------------------------------

```bash
cd ${AOCL_SOURCE}
git clone https://github.com/amd/aocl-libm-ose.git
cd aocl-libm-ose

git checkout aocl-3.1
```

Load modules
------------

```bash
module load ${AOCL_PRGENV}
module swap gcc/10.2.0 gcc/${COMPILER_VERSION}

module load cray-python
module load scons
```

Build LibM
-------------------------

```bash
export CC=gcc
export CXX=g++
export FC=gfortran

scons -j32 install --prefix=${AOCL_MAKE} ALM_CC=/opt/gcc/default/bin/gcc --verbose=1
```


ScaLAPACK
==========

ScaLAPACK is a library of high-performance linear algebra routines for parallel distributed
memory machines. It depends on external libraries including BLAS and LAPACK for linear
algebra computations.


Download the library source code
---------------------------------

```bash
cd ${AOCL_SOURCE}
git clone https://github.com/amd/aocl-scalapack.git
cd aocl-scalapack/
```

Load modules
------------

```bash
module load ${AOCL_PRGENV}
module swap gcc/10.2.0 gcc/${COMPILER_VERSION}
```

Build:
-------

```bash
mkdir build
cd build

cmake .. -DCMAKE_INSTALL_PREFIX=${AOCL_MAKE} -DBUILD_SHARED_LIBS=ON -DBLAS_LIBRARIES=${AOCL_MAKE}/lib/libblis.so -DLAPACK_LIBRARIES=${AOCL_MAKE}/lib/libflame.so -DCMAKE_C_COMPILER=cc -DCMAKE_Fortran_COMPILER=ftn -DUSE_OPTIMIZED_LAPACK_BLAS=OFF

make -j
make install
```



AMD RNG
=======

AMD Random Number Generator (RNG) is a pseudo random number generator library. This is provided as a pre-compiled binary.

Acquire the binary file
---------------------------------

Download the ```aocl-rng-linux-gcc-3.1.0.tar.gz``` from https://developer.amd.com/amd-aocl/rng-library/ and transfer to ARCHER2 ```${AOCL_SOURCE}```.

Upack the file
----------------

```bash

cd ${AOCL_SOURCE}

tar -xvf aocl-rng-linux-gcc-3.1.0.tar.gz
mv amd-rng amd-gcc-rng
```

Obtain the library files
------------------------

```bash
cp amd-gcc-rng/rng/include/* ${AOCL_MAKE}/include/
cp amd-gcc-rng/rng/lib/* ${AOCL_MAKE}/lib/
```


AMD Secure RNG
=======

AMD Secure RNG is a library that provides APIs to access the cryptographically secure random
numbers generated by the AMD hardware random number generator.

Acquire the binary file
---------------------------------

Download the ```aocl-securerng-linux-gcc-3.1.0.tar.gz``` from https://developer.amd.com/amd-aocl/rng-library/ and transfer to ARCHER2 ```${AOCL_SOURCE}```.

Upack the file
----------------

```bash

cd ${AOCL_SOURCE}

tar -xvf aocl-securerng-linux-gcc-3.1.0.tar.gz
mv amd-securerng amd-gcc-securerng
```

Obtain the library files
------------------------

```bash
cp amd-gcc-securerng/include/* ${AOCL_MAKE}/include/
cp amd-gcc-securerng/lib/* ${AOCL_MAKE}/lib/
```


AOCL-Sparse
=============

AOCL-Sparse is a library containing the basic linear algebra subroutines for sparse matrices and vectors optimized for AMD “Zen”-based processors, including EPYCTM, RyzenTM ThreadripperTM PRO, and RyzenTM.

Download the library source code
---------------------------------

```bash
cd ${AOCL_SOURCE}
git clone https://github.com/amd/aocl-sparse.git
cd aocl-sparse/
```

Load modules
------------

```bash
module load ${AOCL_PRGENV}
module swap gcc/10.2.0 gcc/${COMPILER_VERSION}
```

Build
-------------------------

```bash
mkdir -p build/release
cd build/release

cmake ../.. -DCMAKE_INSTALL_PREFIX=${AOCL_MAKE} -DBUILD_CLIENTS_BENCHMARKS=ON

make
make install
```

Test:
```bash
cd tests/staging
export LD_LIBRARY_PATH==${LD_LIBRARY_PATH}:${AOCL_MAKE}/lib
./aoclsparse-bench --function=csrmv --precision=d --sizem=1000 --sizen=1000 --sizennz=4000 --verify=1
```
