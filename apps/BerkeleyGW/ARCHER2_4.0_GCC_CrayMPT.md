# BerkeleyGW 4.0, ARCHER2, GCC

Instructions for compiling BerkeleyGW on ARCHER2 (HPE Cray EX, AMD 7742).

## Download and unpack software

Download the BerkeleyGW software from the website and then unpack:

```
tar -xvf BerkeleyGW-4.0.tar.gz
```

## Setup the config description file

Create a file [archer2.gnu.cpu.epcc.ed.ac.uk.mk](archer2.gnu.cpu.epcc.ed.ac.uk.mk) to contain the configuration options:

```
# arck.mk for ARCHER2 CPU build using GNU compiler
#
# Load the following modules before building:
#
# module restore
# module load PrgEnv-gnu
# module load cray-fftw
# module load cray-hdf5-parallel
# module load cray-libsci
# module load cray-python
#
COMPFLAG = -DGNU
PARAFLAG = -DMPI -DOMP
MATHFLAG = -DUSESCALAPACK -DUNPACKED -DUSEFFTW3 -DHDF5

FCPP = /usr/bin/cpp -C -nostdinc
# F90free = ftn -fopenmp -ffree-form -ffree-line-length-none -fno-second-underscore
# LINK = ftn -fopenmp -dynamic
F90free = ftn -fopenmp -ffree-form -ffree-line-length-none -fno-second-underscore -fbounds-check -fbacktrace -Wall -fallow-argument-mismatch 
LINK = ftn -fopenmp -ffree-form -ffree-line-length-none -fno-second-underscore -fbounds-check -fbacktrace -Wall -fallow-argument-mismatch -dynamic
FOPTS = -O1 -funsafe-math-optimizations -fallow-argument-mismatch
FNOOPTS = $(FOPTS)
MOD_OPT = -J
INCFLAG = -I

C_PARAFLAG = -DPARA -DMPICH_IGNORE_CXX_SEEK
CC_COMP = CC
C_COMP = cc
C_LINK = CC -dynamic
C_OPTS = -O1 -ffast-math
C_DEBUGFLAG =

REMOVE = /bin/rm -f

FFTWINCLUDE = $(FFTW_INC)
PERFORMANCE =

# LAPACKLIB = /pscratch/home/mdelben/LIBS_local/OpenBLAS-0.3.21/libopenblas.a 
# SCALAPACKLIB = /pscratch/home/mdelben/LIBS_local/scalapack-2.1.0/libscalapack.a

HDF5_LDIR = $(HDF5_DIR)/lib
HDF5LIB = $(HDF5_LDIR)/libhdf5hl_fortran.so \
$(HDF5_LDIR)/libhdf5_hl.so \
$(HDF5_LDIR)/libhdf5_fortran.so \
$(HDF5_LDIR)/libhdf5.so -lz -ldl
HDF5INCLUDE =$(HDF5_DIR)/include
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
module load cray-fftw/3.3.10.3
module load cray-python/3.9.13.1
```

## Setup the configuration file

```
cd BerkeleyGW-4.0
cp archer2.gnu.cpu.epcc.ed.ac.uk.mk arch.mk
```

## Build the software

```
make all-flavors -j 16
```

