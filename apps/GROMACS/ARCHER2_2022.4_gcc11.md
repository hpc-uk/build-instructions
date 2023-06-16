Instructions for compiling GROMACS 2022.4 for ARCHER2 using GCC 11 compilers
============================================================================

These instructions are for compiling GROMACS 2022.4 on [ARCHER2](https://www.archer2.ac.uk) using the GCC 11 compilers.


Download and Unpack the GROMACS source code
-------------------------------------------

Download and unpack the source

```bash
wget http://ftp.gromacs.org/pub/gromacs/gromacs-2022.4.tar.gz
tar -xvf gromacs-2022.4.tar.gz
```

Setup correct modules and build environment
-------------------------------------------

Setup the GCC programming environment:

```bash
module load cpe
module load PrgEnv-gnu
module load cray-python
module load cmake
export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH
```

Set compilers to ARCHER2 compiler wrappers

```
export CC=cc
export CXX=CC
```

Configure and build the parallel, single-precision build
--------------------------------------------------------

Create a build directory in the source tree

```bash
cd /path/to/gromacs-2022.4
mkdir build_mpi
cd build_mpi
```

Use CMake to configure the build and then build and install. Remember to set the install 
prefix to somewhere you have permission to write to.

```bash
cmake ../ -DGMX_MPI=ON -DGMX_OPENMP=ON -DGMX_GPU=OFF \
          -DGMX_X11=OFF -DGMX_DOUBLE=OFF             \
          -DGMX_BUILD_OWN_FFTW=ON                    \
          -DCMAKE_INSTALL_PREFIX=/path/to/install
make -j 8
make install
```

Configure and build the parallel, double-precision build
--------------------------------------------------------

Create a build directory in the source tree

```bash
cd /path/to/gromacs-2022.4
mkdir build_double
cd build_double
```

Use CMake to configure the build and then build and install. Remember to set the install 
prefix to somewhere you have permission to write to.

```bash
cmake ../ -DGMX_MPI=ON -DGMX_OPENMP=ON -DGMX_GPU=OFF \
          -DGMX_X11=OFF -DGMX_DOUBLE=ON              \
          -DGMX_BUILD_OWN_FFTW=ON                    \
          -DCMAKE_INSTALL_PREFIX=/path/to/install
make -j 8
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

Use CMake to configure the build and then build and install. Remember to set the install 
prefix to somewhere you have permission to write to.

```bash
cmake ../ -DGMX_MPI=OFF -DGMX_OPENMP=OFF -DGMX_GPU=OFF \
          -DGMX_X11=OFF -DGMX_DOUBLE=OFF               \
          -DGMX_BUILD_OWN_FFTW=ON                      \
          -DCMAKE_INSTALL_PREFIX=/path/to/install
make -j 16
make install
```
