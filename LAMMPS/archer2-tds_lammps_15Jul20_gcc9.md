Building LAMMPS on ARCHER2-TDS (GCC 9.3.0)
===================================================

These instructions are for building LAMMPS on ARCHER2-TDS using the GCC compilers

Download LAMMPS
---------------

Clone the latest stable version of LAMMPS from the GitHub repository:

   `git clone -b stable https://github.com/lammps/lammps.git lammps-20200713`

Setup your environment
----------------------

Load the correct modules:

   ```
   module switch PrgEnv-cray/7.0.0 PrgEnv-gnu/7.0.0
   module load cray-fftw
   ```

MPI Version
-----------

Move to the `src/` directory:

   `cd lammps_20200713/src`

Create MAKE/MACHINE/Makefile.archer2-tds

   `cp MAKE/Makefile.mpi MAKE/MACHINE/Makefile.archer2-tds`

Edit the following in MAKE/MACHINE/Makefile.archer2-tds

   ```
   CC =		CC
   CCFLAGS =	-O3 -Wrestrict
   ```

   ```
   LINK =	CC
   LINKFLAGS =	-O
   LIB = 		-lstdc++
   ```

   ```
   LMP_INC =	-DLAMMPS_GZIP
   ```

   ```
   MPI_INC =       -DMPICH_SKIP_MPICXX
   ```
   
   ```
   FFT_INC= -DFFT_FFTW3
   FFT_LIB= -lfftw3
   ```

Add the packages:

   ```
   make yes-asphere yes-body yes-class2 \
        yes-colloid yes-compress \
        yes-coresphere yes-dipole yes-granular \
        yes-kspace yes-manybody yes-mc \
        yes-misc yes-molecule yes-opt \
        yes-peri yes-qeq yes-replica \
        yes-rigid yes-shock yes-snap \
        yes-srd
   ```

Compile and link:

   `make archer2-tds`

This will create the `lmp_archer2-tds` executable.
