Instructions for compiling GROMACS 2023.4 for Cirrus using GCC 12.3 and Intel MPI 20.4
======================================================================================

These instructions are for compiling GROMACS 2023.4 on [Cirrus](https://www.cirrus.ac.uk) using the GCC 12.3 compilers.

Download and Unpack the GROMACS source code
-------------------------------------------

Download and unpack the source and regression tests

```bash
wget http://ftp.gromacs.org/pub/gromacs/gromacs-2023.4.tar.gz
tar -xf gromacs-2023.4.tar.gz
cd gromacs-2023.4
export SRC=$(pwd)
wget https://ftp.gromacs.org/regressiontests/regressiontests-2023.4.tar.gz
tar xf regressiontests-2023.4.tar.gz
export REG_DIR="$(pwd)/regressiontests-2023.4"
```

Setup correct modules and build environment
-------------------------------------------

```
module load gcc/12.3.0-offload
module load intel-20.4/mpi
module load intel-20.4/cmkl
module load cmake/3.25.2
export CC=mpicc
export CXX=mpicxx
export INSTALL=/work/y07/shared/cirrus-software/GROMACS/2023.4
```

Configure and build the parallel, single-precision build
--------------------------------------------------------

Create a build directory in the source tree

```bash
cd ${SRC}
mkdir build_mpi
cd build_mpi
```

Use CMake to configure the build and then build and install.

```bash
cmake ../ 
      -D CMAKE_CXX_COMPILER=mpicxx        \
      -D CMAKE_C_COMPILER=mpicc           \
      -D GMX_BUILD_OWN_FFTW=ON            \
      -D GMX_DEFAULT_SUFFIX=ON            \
      -D GMX_DOUBLE=OFF                   \
      -D GMX_GPU=OFF                      \
      -D GMX_MPI=ON                       \
      -D GMX_OPENMP=ON                    \
      -D GMX_OPENMP_MAX_THREADS=32        \
      -D GMX_X11=OFF                      \
      -D MPIEXEC=$(which srun)            \
      -D MPIEXEC_EXECUTABLE=$(which srun) \
      -D MPIEXEC_MAX_NUMPROCS=1           \
      -D MPIEXEC_NUMPROC_FLAG=-n          \
      -D REGRESSIONTEST_PATH=${REG_DIR}   \
      -D CMAKE_INSTALL_PREFIX=${INSTALL}  \
      ../

make -j 8
make VERBOSE=1 -j 8 check  # for tests
make install
```


Configure and build the parallel, double-precision build
--------------------------------------------------------

Create a build directory in the source tree

```bash
cd ${SRC}
mkdir build_double
cd build_double
```

Use CMake to configure the build and then build and install.

```bash
cmake ../ 
      -D CMAKE_CXX_COMPILER=mpicxx        \
      -D CMAKE_C_COMPILER=mpicc           \
      -D GMX_BUILD_OWN_FFTW=ON            \
      -D GMX_DEFAULT_SUFFIX=ON            \
      -D GMX_DOUBLE=ON                    \
      -D GMX_GPU=OFF                      \
      -D GMX_MPI=ON                       \
      -D GMX_OPENMP=ON                    \
      -D GMX_OPENMP_MAX_THREADS=32        \
      -D GMX_X11=OFF                      \
      -D MPIEXEC=$(which srun)            \
      -D MPIEXEC_EXECUTABLE=$(which srun) \
      -D MPIEXEC_MAX_NUMPROCS=1           \
      -D MPIEXEC_NUMPROC_FLAG=-n          \
      -D REGRESSIONTEST_PATH=${REG_DIR}   \
      -D CMAKE_INSTALL_PREFIX=${INSTALL}  \
      ../

make -j 8
make VERBOSE=1 -j 8 check  # for tests
make install
```

Configure and build the serial, single-precision build
-------------------------------------------------------

The serial build is required for the GROMACS analysis utilities.

Create a build directory in the source tree

```bash
cd /path/to/gromacs-2022.4
mkdir build_serial
cd build_serial
```

Set the compiler names to the bare compilers:

```bash
export CC=gcc
export CXX=g++
```

Use CMake to configure the build and then build and install.

```bash
cmake ../ 
      -D CMAKE_CXX_COMPILER=g++           \
      -D CMAKE_C_COMPILER=gcc             \
      -D GMX_BUILD_OWN_FFTW=ON            \
      -D GMX_DEFAULT_SUFFIX=ON            \
      -D GMX_DOUBLE=OFF                   \
      -D GMX_GPU=OFF                      \
      -D GMX_MPI=OFF                      \
      -D GMX_OPENMP=OFF                   \
      -D GMX_X11=OFF                      \
      -D REGRESSIONTEST_PATH=${REG_DIR}   \
      -D CMAKE_INSTALL_PREFIX=${INSTALL}  \
      ../

make -j 8
make VERBOSE=1 -j 8 check  # for tests
make install
```
