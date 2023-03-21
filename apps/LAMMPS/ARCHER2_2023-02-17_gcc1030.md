Building LAMMPS v. 17Jun2023 on ARCHER2 (GCC 10.3.0)
====================================================

These instructions are for building LAMMPS on ARCHER2 using the GNU compilers

Download LAMMPS
---------------

Clone the latest stable version of LAMMPS from the GitHub repository:

`git clone --depth=1 -b stable https://github.com/lammps/lammps.git mylammps`

Setup your environment
----------------------

Load the correct modules:

```bash
module load cpe/22.04
module load PrgEnv-gnu/8.1.0
module load cray-fftw/3.3.8.13
module load cmake/3.21.3
module swap gcc/11.2.0 gcc/10.3.0
export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH
```

Compile with CMake
------------------
Create and move into the build directory:

```bash
mkdir mylammps/build ; cd mylammps/build
```

Run CMake:

```bash
cmake ../cmake/ -DCMAKE_CXX_COMPILER=CC -DBUILD_MPI=on -D FFT=FFTW3         \
      -D FFTW3_INCLUDE_DIR=${FFTW_INC}                                      \
      -D FFTW3_LIBRARY=${FFTW_DIR}/libfftw3_mpi.so                          \
      -D PKG_ASPHERE=yes -D PKG_BODY=yes -D PKG_CLASS2=yes -D PKG_RIGID=yes \
      -D PKG_COLLOID=yes -D PKG_COMPRESS=yes -D PKG_CORESHELL=yes           \
      -D PKG_DIPOLE=yes -D PKG_GRANULAR=yes -D PKG_MC=yes -D PKG_MISC=yes   \
      -D PKG_KSPACE=yes -D PKG_MANYBODY=yes -D PKG_MOLECULE=yes             \
      -D PKG_MPIIO=yes -D PKG_OPT=yes -D PKG_PERI=yes -D PKG_QEQ=yes        \
      -D PKG_SHOCK=yes -D PKG_ML-SNAP=yes -D PKG_SRD=yes -D PKG_REAXFF=yes  \
      -D CMAKE_INSTALL_PREFIX=/path/to/install 
make -j 8
make install
```
