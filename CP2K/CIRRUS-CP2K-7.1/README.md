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

In particular, at the time of writing, we do not have a sufficiently
up-to-date Intel 19 to use (cf. the above list).



## Dependencies

Following https://www.cp2k.org/howto:compile we have the following
depencencies

CP2K | Name         | Optional | Build?    | Comment
---- | ----         | -------- | ------    | -------
2a.  | Gnu make     | No       | Available |
2b.  | Python       | No       | Available | `module load anaconda/python2`
2c.  | Fortran/C/C++| No       | Available | via module `intel-18`
2d.  | BLAS/LAPACK  | No       | Available | via module `intel-cmkl-18`
2e.  | MPI?SCLAPACK | Yes      | Available | 
2f.  | FFTW         | Yes      | Avaialble | `module load fftw/3.3.8-intel18`
2g.  | libint       | Yes      | Build     | 
2h.  | libsmm       | Yes      | No        | Using libxsmm
2i.  | libxsmm      | Yes      | Build     |
2j.  | CUDA         | Yes      | --        | See PENDING GPU build
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


# Compile dependencies

The following may be downloaded to a location of choice, but they will all be installed
in `${CP2K_ROOT}/libs`.



## libint

```
$ wget https://github.com/cp2k/libint-cp2k/releases/download/v2.6.0/libint-v2.6.0-cp2k-lmax-4.tgz
$ tar zxvf libint-v2.6.0-cp2k-lmax-4.tgz
$ cd libint-v2.6.0-cp2k-lmax-4

$ CC=icc CXX=icpc FC=ifort ./configure \
                           --enable-fortran --with-cxx-optflags=-O \
                           --prefix=${CP2K_ROOT}/libs/libint

$ make
$ make check
$ make install
```

Notes
* At the install stage the link of a Fortran example may fail with "undefined
reference to main". The link should be carried out with `ifort`, not `icpc`.


## libxsmm

$ wget https://github.com/hfp/libxsmm/archive/1.14.tar.gz
$ tar zxvf 1.14.tar.gz 
$ cd libxsmm-1.14/

$ make CC=icc CXX=icpc FC=ifort INTRINSICS=1 PREFIX=${CP2K_ROOT}/libs/libxsmm install



## libxc

$ wget -O libxc-4.3.4.tar.gz https://www.tddft.org/programs/libxc/down.php?file=
4.3.4/libxc-4.3.4.tar.gz
$ tar zxvf libxc-4.3.4.tar.gz
$ cd libxc-4.3.4/

$ CC=gcc CXX=g++ FC=gfortran ./configure --prefix=${CP2K_ROOT}/libs/libxc
$ make
$ make check
$ make install

## elpa

```
$ wget http://elpa.mpcdf.mpg.de/html/Releases/2019.11.001/elpa-2019.11.001.tar.g
z
$ tar zxvf elpa-2019.11.001.tar.gz 
$ cd elpa-2019.11.001/

$ mkdir build-serial
$ cd build-serial/
$ CC=mpiicc CXX=mpiicpc FC=mpiifort FCFLAGS=-mkl=sequential  \
             LIBS="-lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core \
                   -lmkl_blacs_intelmpi_lp64 -lpthread -lm -ldl"   \
             ../configure --enable-openmp=no --disable-avx512 \
                          --prefix=${CP2K_ROOT}/libs/elpa
$ make
$ make check
$ make install
```

Notes:

* Use the Intel link-line advisor to get the right incantation
 for MKL blacs and scalapack. Set the "link explicitly" option.
 https://software.intel.com/en-us/articles/intel-mkl-link-line-advisor
* `--disable-avx512` is required to prevent illegal instructions in tests
* make check. [make -j to run more quckly] PASS 41 SKIP 56 FAIL 7; of
  the fails, the log shows these are small tolerance failures so
  assume acceptable.
* `--enable-scalapack-tests` may be responsible for skips, but does not
  work in the tar release as `test/shared/test_scalapack.F90` is missing.
  Would have to try gitlab pull of 2019.11.001 branch.


### elpa OpenMP version

```
$ mkdir build-open
$ cd build-openmp

$ CC=mpiicc CXX=mpiicpc FC=mpiifort FCFLAGS=-mkl=parallel  \
            LIBS="-lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core \
                  -lmkl_blacs_intelmpi_lp64 -lpthread -lm -ldl" \
                  ../configure --enable-openmp=yes --disable-avx512 \
                  --prefix=${CP2K_ROOT}/libs/elpa-openmp

$ make
$ make check
$ make install
```

Notes

* Use intel link line advisor again with OpenMP threading option (iomp5)
* `make check` gives same pass/skip/fail as the serial version


##  plumed

```
$ CC=mpiicc CXX=mpiicpc FC=mpiifort MPIEXEC=mpirun ./configure \
            --disable-openmp --prefix=${CP2K_ROOT}/libs/plumed
$ make
$ make test
$ make check
$ make install
```

* `./src/lib` should be added to `LD_LIBRARY_PATH` in order that `make test`
  can locate `./src/lib/libplumedKernel.so`
* `make check` reports 8 failures, which look like small deviations, so
  assume acceptable. 289 run 203 skip 8 fail

### plumed OpenMP version

```
$ CC="mpiicc -qopenmp" CXX="mpiicpc -qopenmp" FC="mpiifort -qopenmp" MPIEXEC=mpirun \
     ./configure --prefix=${CP2K_ROOT}/libs/plumed-openmp
```

Notes

* Combine the `-qopenmp` with the compiler to ensure it always appears at
  link time (using `LDFLAGS` does not do so).
* `make check` gives more failures 289 run 203 skip 15 errors. However,
  some of the errors include NaN, so assume not reliable.

We shall thus use only the serial version of PLUMED


## spglib

From https://github.com/atztogo/spglib

```
$ wget https://github.com/atztogo/spglib/archive/v1.11.2.1.tar.gz
$ tar zxvf v1.11.2.1.tar.gz 
$ cd spglib-1.11.2.1

$ aclocal
$ autoheader
$ libtoolize
$ touch INSTALL NEWS README AUTHORS
$ automake -acf
$ autoconf

$ CC=icc ./configure --prefix=${CP2K_ROOT}/libs/spglib
$ make
$ make check
$ make install
```

Notes
* This is a serial build; no parallel build is relevant.
* `make`: it may be necessary to run `aclocal` again the first time around.



# Compile CP2K


