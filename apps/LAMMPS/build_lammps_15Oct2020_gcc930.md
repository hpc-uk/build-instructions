Building LAMMPS on ARCHER2 (GCC 9.3.0)
===================================================

These instructions are for building LAMMPS on ARCHER2 using the GNU compilers

Download LAMMPS
---------------

Clone the latest stable version of LAMMPS from the GitHub repository:

   `git clone -b stable https://github.com/lammps/lammps.git mylammps`

Setup your environment
----------------------

Load the correct modules:

   ```bash
   module restore PrgEnv-gnu
   module load cray-fftw
   ```

Compile with make
-----------------

.. note::

  Compiling with make does not seem to work with most recent version of LAMMPS.
  We recommend using the cmake method if using newer versions of LAMMPS.

Move to the `src/` directory:

   `cd mylammps/src`

Create MAKE/MACHINE/Makefile.archer2

   `cp MAKE/Makefile.mpi MAKE/MACHINES/Makefile.archer2`

Edit the following in MAKE/MACHINES/Makefile.archer2

   ```bash
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

   ```bash
   make yes-asphere yes-body yes-class2 \
        yes-colloid yes-compress \
        yes-coreshell yes-dipole yes-granular \
        yes-kspace yes-manybody yes-mc \
        yes-misc yes-molecule yes-opt \
        yes-peri yes-qeq yes-replica \
        yes-rigid yes-shock yes-snap \
        yes-srd
   ```

Compile and link:

   `make -j 8 archer2`

This will create the `lmp_archer2` executable.

Compile with CMake
------------------
Create and move into the build directory:

  `mkdir mylammps/build ; cd mylammps/build`

Load the CMake module:

  `module load cmake`

Run CMake:

  ```
  cmake -DCMAKE_CXX_COMPILER=CC -DBUILD_MPI=on -D FFT=FFTW3                   \
        -D FFTW3_INCLUDE_DIR=${FFTW_INC}                                      \
        -D FFTW3_LIBRARY=${FFTW_DIR}/libfftw3_mpi.so                          \
        -D PKG_ASPHERE=yes -D PKG_BODY=yes -D PKG_CLASS2=yes                  \
        -D PKG_COLLOID=yes -D PKG_COMPRESS=yes -D PKG_CORESHELL=yes           \
        -D PKG_DIPOLE=yes -D PKG_GRANULAR=yes -D PKG_MC=yes -D PKG_MISC=yes   \
        -D PKG_KSPACE=yes -D PKG_MANYBODY=yes -D PKG_MOLECULE=yes             \
        -D PKG_MPIIO=yes -D PKG_OPT=yes -D PKG_PERI=yes -D PKG_QEQ=yes        \
        -D PKG_SHOCK=yes -D PKG_SNAP=yes -D PKG_SRD=yes -D PKG_USER-REAXC=yes \
        -D PKG_RIGID=yes ../cmake/
  make -j 8
  ```
  
If using a version compiled with CMake, you will need to include the following 
in your Slurm submission scripts at runtime:

  `module restore /etc/cray-pe.d/PrgEnv-gnu`
