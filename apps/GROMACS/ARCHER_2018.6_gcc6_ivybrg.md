Instructions for compiling GROMACS 2018.6 for ARCHER using GCC 6 compilers
==========================================================================

These instructions are for compiling GROMACS on ARCHER (Intel Ivy Bridge processors)
using the GCC 6 compilers.
Below only 2018.6 is mentioned, the process for versions 2019.1, 2019.3 and 2020.1 are the same.

Download and Unpack the GROMACS source code
-------------------------------------------

Download and unpack the source

```bash
wget http://ftp.gromacs.org/pub/gromacs/gromacs-2018.6.tar.gz
tar -xvf gromacs-2018.6.tar.gz
```

Setup correct modules
---------------------

Switch to the GNU programming environment:

```bash
module swap PrgEnv-cray PrgEnv-gnu
```

and load the fftw and CMake modules:

```bash
module load fftw/3.3.4.11
module load cmake
```

Configure and build the parallel, single-precision build
--------------------------------------------------------

Create a build directory in the source tree

```bash
cd gromacs-2018.6
mkdir build_mpi
cd build_mpi
```

Set the environment variables for the CMake build. (Note, for at least
4.6.3 and 4.6.5, FLAGS=-ffast-math results in errors and test failures.)

```bash
export CXX=CC
export CC=cc
export CMAKE_PREFIX_PATH=/opt/cray/fftw/3.3.4.11/sandybridge/lib
export FLAGS="-dynamic -O3 -ftree-vectorize -funroll-loops"
```

Use CMake to configure the build and then build and install. Remember to set the install 
prefix to somewhere you have permission to write to.

```bash
cmake ../ -DGMX_MPI=ON -DGMX_OPENMP=ON -DGMX_GPU=OFF -DGMX_X11=OFF -DGMX_DOUBLE=OFF \
          -DCMAKE_C_FLAGS="$FLAGS" -DCMAKE_CXX_FLAGS="$FLAGS" -DGMX_BUILD_MDRUN_ONLY=ON  \
          -DGMX_BUILD_OWN_FFTW=OFF \
          -DCMAKE_INSTALL_PREFIX=/work/y07/y07/gmx/2018.6-gcc6
make -j 8 install
```

Version 2020.1 of GROMACS needs the additional flag to find the FFTW library `-DFFTWF_INCLUDE_DIR="$FFTW_INC"`

Configure and build the parallel, double-precision build
--------------------------------------------------------

Create a build directory in the source tree

```bash
cd gromacs-2018.6
mkdir build_mpi_d
cd build_mpi_d
```

Set the environment variables for the CMake build. (Note, for at least 4.6.3 and 4.6.5,
FLAGS=-ffast-math results in errors and test failures.)

```bash
export CXX=CC
export CC=cc
export CMAKE_PREFIX_PATH=/opt/cray/fftw/3.3.4.11/sandybridge/lib
export FLAGS="-dynamic -O3 -ftree-vectorize -funroll-loops"
```

Use CMake to configure the build and then build and install. Remember to set the install 
prefix to somewhere you have permission to write to.

```bash
cmake ../ -DGMX_MPI=ON -DGMX_OPENMP=ON -DGMX_GPU=OFF -DGMX_X11=OFF -DGMX_DOUBLE=ON \
          -DCMAKE_C_FLAGS="$FLAGS" -DCMAKE_CXX_FLAGS="$FLAGS" -DGMX_BUILD_MDRUN_ONLY=ON  \
          -DGMX_BUILD_OWN_FFTW=OFF \
          -DCMAKE_INSTALL_PREFIX=/work/y07/y07/gmx/2018.6-gcc6
make -j 8 install
```

Version 2020.1 of GROMACS needs the additional flag to find the FFTW library: `-DFFTW_INCLUDE_DIR="$FFTW_INC"`
