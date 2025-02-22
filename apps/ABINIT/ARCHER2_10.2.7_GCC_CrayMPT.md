
# ABINIT 10.2.7, ARCHER2, GCC

Instructions for compiling ABINIT 10.2.7 on ARCHER2 (HPE Cray EX, AMD 7742).

## Download and unpack software

```
wget https://forge.abinit.org/abinit-10.2.7.tar.gz
tar -xvf 10.2.7.tar.gz
```

## Setup the config description file

Create a file [archer2.ac9](archer2.ac9) to contain the configuration options:

```
#---
#{
#"hostname": "ARCHER2",
#"author": "A. Turner, EPCC",
#"date": "2025-02-21",
#"description": [
#   "Configuration file for ARCHER2 using GCC."
#],
#"qtype": "slurm",
#"keywords": ["linux", "cray", "mpich"],
#"pre_configure": [
#   "module restore",
#   "module load PrgEnv-gnu",
#   "module load gcc/11.2.0",
#   "module load cray-mpich/8.1.23",
#   "module load cray-libsci/22.12.1.1",
#   "module load cray-hdf5-parallel/1.12.2.1",
#   "module load cray-netcdf-hdf5parallel/4.9.0.1",
#   "module load cray-fftw/3.3.10.3",
#   "module load cray-python/3.9.13.1"
# ]
#}
#---

CC=cc
FC=ftn
CXX=CC
F90=ftn

CFLAGS="        -O3 " #-mtune=skylake -xCORE-AVX512 -m64 -fPIC -mkl "
CXXFLAGS="          "
FCFLAGS="       -O3 -g -fopenmp -fallow-argument-mismatch -ffree-form -ffree-line-length-none "
FCFLAGS_OPTIM=" -O3 "
FCFLAGS_EXTRA=" "
FCFLAGS_MODDIR="-I../mods"

with_mpi='yes'
enable_mpi_inplace='yes'
enable_mpi_io='yes'
enable_openmp='yes'

with_linalg_flavor="netlib"

with_fft_flavor="fftw3"
with_fftw3=${FFTW_DIR}

with_hdf5='yes'

with_netcdf=${NETCDF_DIR}
with_netcdf_fortran=${NETCDF_DIR}

with_libxc=/mnt/lustre/a2fs-work4/work/y07/shared/libs/compiler/gnu/8.0/libxc/7.0.0
```
## Load modules to setup the GCC compiler environment

The following commands setup the build environment:

```
module restore
module load PrgEnv-gnu
module load gcc/11.2.0
module load cray-mpich/8.1.23
module load cray-libsci/22.12.1.1
module load cray-hdf5-parallel/1.12.2.1
module load cray-netcdf-hdf5parallel/4.9.0.1
module load cray-fftw/3.3.10.3
module load cray-python/3.9.13.1
```

## Setup the build directory and configure

```
cd abinit-10.2.7
builddir="_build_gcc_mpi"

mkdir $builddir

cd $builddir

../configure --with-config-file="../archer2.ac9"
```

## Build the software

```
make -j8
```

The `abinit` binary will be at `abinit-10.2.7/_build_gcc_mpi/src/98_main/abinit`.

If you want the binaries in a specific install location specify the `prefix` option at 
configure step to point to a directory where you have write permissions.
