Building LAMMPS on ARCHER2 (GCC 10.2.0)
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
   module restore
   module swap PrgEnv-cray PrgEnv-gnu 
   module load cray-fftw
   module load cmake
   ```

Compile with cmake
------------------
Create and move into the build directory:

  `mkdir mylammps/build ; cd mylammps/build`

Run CMake:

  ```
  cmake -DCMAKE_CXX_COMPILER=CC -DBUILD_MPI=on -D FFT=FFTW3         \
        -D FFTW3_INCLUDE_DIR=${FFTW_INC}                            \
        -D FFTW3_LIBRARY=${FFTW_DIR}/libfftw3_mpi.so                \
        -D PKG_ASPHERE=yes -D PKG_BODY=yes -D PKG_CLASS2=yes        \
        -D PKG_COLLOID=yes -D PKG_COMPRESS=yes -D PKG_CORESHELL=yes \
        -D PKG_DIPOLE=yes -D PKG_GRANULAR=yes -D PKG_MC=yes         \
        -D PKG_MISC=yes -D PKG_KSPACE=yes -D PKG_MANYBODY=yes       \
        -D PKG_MOLECULE=yes -D PKG_MPIIO=yes -D PKG_OPT=yes         \
        -D PKG_PERI=yes -D PKG_QEQ=yes -D PKG_SHOCK=yes             \
        -D PKG_SRD=yes -D PKG_RIGID=yes                             \
        ../cmake/
  make -j 8
  ```

This will create an executable called `lmp` in `mylammps/build`.
