# Introduction

These instructions are for building CP2K version 9.1 on Cirrus.

A number of different compilers are available on Cirrus, so following
the list at  https://www.cp2k.org/dev:compiler_support

```
module load intel-20.4/compilers intel-20.4/mpi intel-20.4/cmkl
```
being the modules for Intel MPI, Intel compilers, and the math kernel
library MKL.


## Dependencies

Following https://www.cp2k.org/howto:compile we have the following
depencencies

CP2K | Name         | Optional | Build?    | Comment
---- | ----         | -------- | ------    | -------
2a.  | Gnu make     | No       | Available |
2b.  | Python       | No       | Available | `module load anaconda/python3`
2c.  | Fortran/C/C++| No       | Available | via module `intel-20.4/compilers`
2d.  | BLAS/LAPACK  | No       | Available | via module `intel-20.4/cmkl`
2e.  | MPI?SCLAPACK | Yes      | Available | 
2f.  | FFTW         | Yes      | Avaialble | No suitable module available
2g.  | libint       | Yes      | Build     | 
2h.  | libsmm       | Yes      | No        | Using libxsmm
2i.  | libxsmm      | Yes      | Build     |
2j.  | CUDA         | Yes      | --        | CPU build only
2k.  | libxc        | Yes      | Build     |
2l.  | ELPA         | Yes      | Build     |
2m.  | PEXSI        | Yes      | No        | Not required
2n.  | QUIP         | Yes      | No        | Not required
2o.  | PLUMED       | Yes      | Build     |
2p.  | spglib       | Yes      | Build     | 
2q.  | SIRIUS       | Yes      | No        | Not required
2r.  | FPGA         | Yes      | --        | Not relevant


## Preliminaries



### Set `CP2K_ROOT`

From the CP2K web site, download the appropriate release of the code: 

```
wget https://github.com/cp2k/cp2k/releases/download/v9.1.0/cp2k-9.1.tar.bz2
```
Note: here we get the `.bz2` bundle as it contains the DBCSR submodule
(the `.tar.gz` does not for some reason).

Untar this into a location on the `/work` file system:
 ```
bunzip2 cp2k-9.1.tar.bz2
tar xvf cp2k-9.1.tar
cd cp2k-9.1
ls
COPYRIGHT   LICENSE   README.md  arch        data  src    tools
INSTALL.md  Makefile  REVISION   benchmarks  exts  tests
export CP2K_ROOT=`pwd`
```

Note we have set the environment variable `CP2K_ROOT` to be the top-level
CP2K directory. We will refer to this in what follows.


# Compile dependencies

The following may be downloaded to a location of choice, but they will all be installed
in `${CP2K_ROOT}/libs`.


## FFTW

```
wget http://www.fftw.org/fftw-3.3.10.tar.gz
tar xvf fftw-3.3.10.tar.gz
cd fftw-3.3.10
CC=mpiicc CXX=mpiicpc FC=mpiifort MPICC=mpiicc ./configure
  \ --enable-openmp --disable-shared --enable-static --disable-avx512 --enable-mpi \
    --prefix=$(CP2K_ROOT)/libs/fftw
make -j8
make install
```

## libint

```
wget https://github.com/cp2k/libint-cp2k/releases/download/v2.6.0/libint-v2.6.0-cp2k-lmax-4.tgz
tar zxvf libint-v2.6.0-cp2k-lmax-4.tgz
cd libint-v2.6.0-cp2k-lmax-4

CC=icc CXX=icpc FC=ifort ./configure \
                           --enable-fortran --with-cxx-optflags=-O \
                           --prefix=${CP2K_ROOT}/libs/libint

make -j8
make install
```

Notes

* At the install stage the link of a Fortran example may fail with "undefined
reference to main". The link should be carried out with `ifort`, not `icpc`.


## libxsmm

```
wget https://github.com/hfp/libxsmm/archive/1.17.tar.gz
tar zxvf 1.17.tar.gz 
cd libxsmm-1.17/

make CC=icc CXX=icpc FC=ifort INTRINSICS=1 PREFIX=${CP2K_ROOT}/libs/libxsmm install
```


## libxc

```
wget -O libxc-5.1.7.tar.gz \
      https://www.tddft.org/programs/libxc/down.php?file=5.1.7/libxc-5.1.7.tar.gz
tar zxvf libxc-5.1.7.tar.gz
cd libxc-5.1.7/

CC=icc CXX=icpc FC=ifort ./configure --prefix=${CP2K_ROOT}/libs/libxc
make -j8
make install
```

## ELPA

```
wget https://elpa.mpcdf.mpg.de/software/tarball-archive/Releases/2021.11.002/elpa-2021.11.002.tar.gz
tar zxvf elpa-2021.11.002.tar.gz 
cd elpa-2021.11.002/
mkdir build-openmp
cd build-openmp

CC=mpiicc CXX=mpiicpc FC=mpiifort FCFLAGS=-mkl=parallel  \
            LIBS="-lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core \
                  -lmkl_blacs_intelmpi_lp64 -lpthread -lm -ldl" \
                  ../configure --enable-openmp=yes --disable-avx512 \
                  --prefix=${CP2K_ROOT}/libs/elpa-openmp

make -j8
make install
```

Notes:

* Use the Intel link-line advisor to get the right incantation
 for MKL blacs and scalapack. Set the "link explicitly" option.
 https://software.intel.com/en-us/articles/intel-mkl-link-line-advisor
* `--disable-avx512` is required to prevent illegal instructions in tests
* `make check`. [`make -j` to run more quckly] PASS 41 SKIP 56 FAIL 7; of
  the fails, the log shows these are small tolerance failures so
  assume acceptable.
* `--enable-scalapack-tests` may be responsible for skips, but does not
  work in the tar release as `test/shared/test_scalapack.F90` is missing.
  Would have to try gitlab pull of 2019.11.001 branch.



##  PLUMED

```
wget https://github.com/plumed/plumed2/releases/download/v2.7.4/plumed-2.7.4.tgz
tar xvf plumed-2.7.4.tgz
cd plumed-2.7.4
CC=mpiicc CXX=mpiicpc FC=mpiifort MPIEXEC=mpirun ./configure \
           --disable-openmp --prefix=${CP2K_ROOT}/libs/plumed
make -j8 
make install
```

## spglib

```
git clone https://github.com/spglib/spglib.git
cd spglib
git checkout v1.16.2
mkdir build
cd build
module load cmake
CC=mpiicc CXX=mpiicpc FC=mpiifort cmake -DCMAKE_INSTALL_PREFIX=$(CP2K_ROOT)/libs/spglib ..
make -j8
make install
```

Notes
* This is a serial build; no parallel build is relevant.



# Compile CP2K

The following modules are loaded
```
module load intel-20.4/compilers intel-20.4/mpi intel-20.4/cmkl
module load anaconda/python3
```
Note the addition of an appropriate `FFTW`, and `gcc` for the standard C++ library
via `-lstdc++` used by Intel.

With the associated [./Cirrus-intel.psmp](./Cirrus-intel.psmp) arch file

```
make -j 12 ARCH=Cirrus-intel VERSION=psmp
```

# Tests

SUMMARY

Number of FAILED  tests 1
Number of WRONG   tests 3
Number of CORRECT tests 3634
Total number of   tests 3638

FAILED test
* opt_basis_O_auto_gen.inp due to Intel mem leak in mp2_optimize_ri_basis.F

WRONG tests
* water_atprop_ewald.inp
* CH3-ADMM.inp
* 2d_pot.inp

Only slightly outside tolerances

