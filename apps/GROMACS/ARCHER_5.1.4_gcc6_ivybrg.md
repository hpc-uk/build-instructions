Instructions for compiling GROMACS 5.1.4 for ARCHER using GCC 6 compilers
=========================================================================

These instructions are for compiling GROMACS 5.1.4 on ARCHER (Intel Ivy Bridge processors)
using the GCC 6 compilers.

*Note:* GROMACS ust be built on the /work file system as it is a dynamic executable and has
library files that will be required at runtime.

Download and Unpack the GROMACS source code
-------------------------------------------

Download and unpack the source

```bash
wget ftp://ftp.gromacs.org/pub/gromacs/gromacs-5.1.4.tar.gz
tar -xvf gromacs-5.1.4.tar.gz
```

Setup correct modules
---------------------

Switch to the GNU programming environment:

```bash
module swap PrgEnv-cray PrgEnv-gnu
module swap gcc gcc/6.1.0
```

and load the FFTW 3 and CMake modules:

```bash
module add fftw/3.3.4.9
module add cmake
```

Configure and build the parallel, single-precision build
--------------------------------------------------------

Create a build directory in the source tree

```bash
cd gromacs-5.1.4
mkdir build_mpi
cd build_mpi
```

Set the environment variables for the CMake build. (Note, for at least
4.6.3 and 4.6.5, FLAGS=-ffast-math results in errors and test failures.)

```bash
export CXX=CC
export CC=cc
export CMAKE_PREFIX_PATH=/opt/cray/fftw/3.3.4.9/sandybridge/lib
export FLAGS="-dynamic -O3 -ftree-vectorize -funroll-loops"
```

Use CMake to configure the build and then build and install. Remember to set the install 
prefix to somewhere you have permission to write to.

```bash
cmake ../ -DGMX_MPI=ON -DGMX_OPENMP=ON -DGMX_GPU=OFF -DGMX_X11=OFF -DGMX_DOUBLE=OFF \
          -DCMAKE_C_FLAGS="$FLAGS" -DCMAKE_CXX_FLAGS="$FLAGS" -DGMX_BUILD_MDRUN_ONLY=ON  \
          -DFFTWF_INCLUDE_DIR=/opt/cray/fftw/3.3.4.9/ivybridge/include \
          -DCMAKE_INSTALL_PREFIX=/work/y07/y07/gmx/5.1.4
make -j 8 install
```

Configure and build the parallel, double-precision build
--------------------------------------------------------

Create a build directory in the source tree

```bash
cd gromacs-5.1.4
mkdir build_mpi_d
cd build_mpi_d
```

Set the environment variables for the CMake build. (Note, for at least 4.6.3 and 4.6.5,
FLAGS=-ffast-math results in errors and test failures.)

```bash
export CXX=CC
export CC=cc
export CMAKE_PREFIX_PATH=/opt/cray/fftw/3.3.4.9/sandybridge/lib
export FLAGS="-dynamic -O3 -ftree-vectorize -funroll-loops"
```

Use CMake to configure the build and then build and install. Remember to set the install 
prefix to somewhere you have permission to write to.

```bash
cmake ../ -DGMX_MPI=ON -DGMX_OPENMP=ON -DGMX_GPU=OFF -DGMX_X11=OFF -DGMX_DOUBLE=ON \
          -DCMAKE_C_FLAGS="$FLAGS" -DCMAKE_CXX_FLAGS="$FLAGS" -DGMX_BUILD_MDRUN_ONLY=ON  \
          -DFFTWF_INCLUDE_DIR=/opt/cray/fftw/3.3.4.9/ivybridge/include \
          -DCMAKE_INSTALL_PREFIX=/work/y07/y07/gmx/5.1.4
make -j 8 install
```


