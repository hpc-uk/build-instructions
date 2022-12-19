# Introduction

These instructions are for building CP2K version 8.2 for Cirrus GPU.

A number of different compilers are available on Cirrus. GCC is 
recomended but cannot be used with mpt due to the lack of the Fortran
MPI module. Therefore we use it with intel-mpi.

The following modules are loaded.

```
module load intel-mpi-18
module load intel-cmkl-18
module load nvidia/cuda-11.2
module load nvidia/mathlibs-11.2
module swap gcc/6.3.0 gcc/8.2.0
```

Note that this build does not consider autotuning of libgrid, and only
discusses the CP2K psmp build.


## Dependencies

Following https://www.cp2k.org/howto:compile we have the following
depencencies

CP2K | Name         | Optional | Build?    | Comment
---- | ----         | -------- | ------    | -------
2a.  | Gnu make     | No       | Available |
2b.  | Python       | No       | Available | `module load anaconda/python2`
2c.  | Fortran/C/C++| No       | Available | via module `gcc8.2`
2d.  | BLAS/LAPACK  | No       | Available | via module `intel-cmkl-18`
2e.  | MPI?SCLAPACK | Yes      | Available | 
2f.  | FFTW         | Yes      | Avaialble | `module load fftw/3.3.8-intel18`
2g.  | libint       | Yes      | Build     | 
2h.  | libsmm       | Yes      | No        | Using libxsmm
2i.  | libxsmm      | Yes      | Build     |
2j.  | CUDA         | Yes      | Available | `module load cuda/cudamathlibs`
2k.  | libxc        | Yes      | Build     |
2l.  | ELPA         | Yes      | Build     |
2m.  | PEXSI        | Yes      | No        | Not required
2n.  | QUIP         | Yes      | No        | Not required
2o.  | PLUMED       | Yes      | Build     |
2p.  | spglib       | Yes      | Build     | 
2q.  | SIRIUS       | Yes      | No        | Not required
2r.  | FPGA         | Yes      | --        | Not relevant
2s.  | COSMA        | Yes      | Build     |
2t.  | LibVori      | Yes      | --        | Not required
2u.  | ROCM/HIP     | Yes      | --        | Not relevant
2v.  | OpenCL       | Yes      | --        | Not relevant


## Preliminaries



### Set `CP2K_ROOT`

From the CP2K web site, download the appropriate release of the code: 

```
$ wget https://github.com/cp2k/cp2k/releases/download/v8.2.0/cp2k-8.2.tar.bz2
```
Note: here we get the `.bz2` bundle as it contains the DBCSR submodule
(the `.tar.gz` does not for some reason).

 Untar this into a location on the `/work` file system:
 ```
 bunzip2 cp2k-8.2.tar.bz2
 tar xvf cp2k-8.2.tar
 cd cp2k-8.2
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



## libint

```
wget https://github.com/cp2k/libint-cp2k/releases/download/v2.6.0/libint-v2.6.0-cp2k-lmax-4.tgz
tar zxvf libint-v2.6.0-cp2k-lmax-4.tgz
cd libint-v2.6.0-cp2k-lmax-4

CC=gcc CXX=g++ FC=gfortran ./configure \
                           --enable-fortran --with-cxx-optflags=-O \
                           --prefix=${CP2K_ROOT}/libs/libint

make
make check
make install
```

## libxsmm

```
wget https://github.com/hfp/libxsmm/archive/refs/tags/1.16.1.tar.gz
tar zxvf 1.16.1.tar.gz 
cd libxsmm-1.16.1/

make CC=gcc CXX=g++ FC=gfortran INTRINSICS=1 PREFIX=${CP2K_ROOT}/libs/libxsmm install
```


## libxc

```
wget -O libxc-5.1.4.tar.gz \
      https://www.tddft.org/programs/libxc/down.php?file=5.1.4/libxc-5.1.4.tar.gz
tar zxvf libxc-5.1.4.tar.gz
cd libxc-5.1.4/

CC=gcc CXX=g++ FC=gfortran ./configure --prefix=${CP2K_ROOT}/libs/libxc
make
make check
make install
```

## ELPA

### ELPA OpenMP version

```
module load libtool
wget https://elpa.mpcdf.mpg.de/software/tarball-archive/Releases/2020.11.001/elpa-2020.11.001.tar.gz
tar zxvf elpa-2020.11.001.tar.gz
cd  elpa-2020.11.001

mkdir build-gpu
cd build-gpu

CC=mpicc CXX=mpicxx FC=mpif90 CFLAGS="-march=skylake-avx512"  \
            LIBS="-lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core \
                  -lmkl_blacs_intelmpi_lp64 -lpthread -lm -ldl" \
                  ../configure --enable-openmp=yes --enable-gpu=yes --disable-avx512 \
                  --prefix=${CP2K_ROOT}/libs/elpa-gpu

make
make check
make install
```

Notes

* Use intel link line advisor again with OpenMP threading option (iomp5)
* `make check` gives same pass/skip/fail as the serial version


##  PLUMED

```
CC=mpicc CXX=mpicxx FC=mpif90 MPIEXEC=srun ./configure \
            --disable-openmp --prefix=${CP2K_ROOT}/libs/plumed
make
make test
make check
make install
```

* `./src/lib` should be added to `LD_LIBRARY_PATH` in order that `make test`
  can locate `./src/lib/libplumedKernel.so`


## SpgLib

## COSMA

```
module load cmake
wget https://github.com/eth-cscs/COSMA/archive/refs/tags/v2.5.0.tar.gz
tar zxvf v2.5.0.tar.gz
cd  COSMA-2.5.0/
export CC=mpicc CXX=mpicxx
export LIBS="-lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core \
             -lmkl_blacs_intelmpi_lp64 -lpthread -lm -ldl"
mkdir build
cd build
cmake -DCOSMA_BLAS=MKL -DCOSMA_SCALAPACK=MKL -DCMAKE_INSTALL_PREFIX=${CP2K_ROOT}/libs/cosma ..
make
make install
```


# Compile CP2K

The following modules are loaded
```
module load intel-mpi-18
module load intel-cmkl-18
module load nvidia/cuda-11.2
module load nvidia/mathlibs-11.2
module swap gcc/6.3.0 gcc/8.2.0
module load anaconda/python3
```


Compile using the associated [./Cirrus-gcc-gpu.psmp](./Cirrus-gcc-gpu.popt) arch file
using a job script (to compile on a GPU).

```
#!/bin/bash
#
#SBATCH --partition=gpu
#SBATCH --qos=gpu
#SBATCH --gres=gpu:1
#SBATCH --time=00:20:00

# Replace [budget code] below with your project code (e.g. t01)
#SBATCH --account=[budget code]

# Load the required modules
module load intel-mpi-18
module load intel-cmkl-18
module load nvidia/cuda-11.2
module load nvidia/mathlibs-11.2
module swap gcc/6.3.0 gcc/8.2.0
module load anaconda/python3

# build CP2K
make ARCH=Cirrus-gcc-gpu VERSION=psmp
```

# Tests

All the regression tests pass to the default tolerance.
