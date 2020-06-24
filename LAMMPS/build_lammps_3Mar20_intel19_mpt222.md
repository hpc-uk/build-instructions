Building LAMMPS on Cirrus (Intel 19, SGI MPT 2.22)
===================================================

These instructions are for building LAMMPS on Cirrus (SGI/HPE ICE XA, Intel Broadwell)
using the Intel 19 compilers and MPI from SGI MPT 2.22.

Download LAMMPS
---------------

Clone the latest stable version of LAMMPS from the GitHub repository:

   git clone -b stable https://github.com/lammps/lammps.git lammps_20200303

Setup your environment
----------------------

Load the correct modules:

   module load intel-compilers-19
   module load mpt
   module load fftw/3.3.8-intel19
   module load zlib/1.2.11

MPI Version
-----------

Move to the `src/` directory:

   cd lammps_20200303/src

Edit MAKE/Makefile.mpi to set the following
   CC =		mpicxx -cxx=icpc
   CCFLAGS =	-restrict -g -O3

   LINK =	mpicxx -cxx=icpc
   LINKFLAGS =	-restrict -g -O3
  
   FFT_INC= -DFFT_FFTW3
   FFT_LIB= -lfftw3

Add the packages:

   make yes-kspace yes-manybody yes-molecule \
        yes-asphere yes-body yes-class2 \
        yes-colloid yes-compress yes-coreshell \
        yes-dipole yes-granular yes-mc yes-misc \
        yes-mpiio yes-opt yes-peri yes-qeq \
        yes-shock yes-snap yes-srd \
        yes-user-reaxc yes-misc yes-rigid \
        yes-replica

Compile and link:

   make -j8 mpi

This will create the `lmp_mpi` executable.

Serial Version
--------------

Edit `MAKE/Makefile.serial` to set the following
   CC =		icpc
   CCFLAGS =	-restrict -g -O3

   LINK =	icpc
   LINKFLAGS =	-restrict -g -O3
   
   FFT_INC= -DFFT_FFTW3
   FFT_LIB= -lfftw3

Remove MPI-IO from the build:

   make no-mpiio

Clean, compile and link:

   make clean-all
   make -j8 serial

This will create the `lmp_serial` executable.
